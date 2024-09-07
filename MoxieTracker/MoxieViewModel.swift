import SwiftUI
import WidgetKit
import MoxieLib
import Combine

enum NotificationOption: Codable, Hashable {
	case hour
	case week
	case month
	case custom(String)
}

@MainActor
final class MoxieViewModel: ObservableObject, Observable {
	static let shared = MoxieViewModel()
	
	var inFlightTask: Task<Void, Error>?
	
	@Published var persistence: UserDefaults

	@Published var input: String
	@Published var model: MoxieModel
	
	@Published var isLoading: Bool = false
	@Published var price: Decimal = 0
	@Published var timeAgo: String = ""
	@Published var userInputNotifications: Decimal
	@Published var isSearchMode: Bool
	@Published var moxieChangeText: String = ""
	@Published var isNotificationSheetPresented: Bool = false

	@Published var selectedNotificationOptions: [NotificationOption] = []
	
	@Published var filterSelection: Int
	@Published var error: Error?

	@Published var dollarValueMoxie: Decimal = 0
	
	@Published var inputFID: Int

	private let client: MoxieProvider
	
	private(set) var subscriptions: Set<AnyCancellable> = []
	
	init(input: String = "",
			 model: MoxieModel = .noop,
			 isLoading: Bool = false,
			 client: MoxieProvider = MoxieClient(),
			 isSearchMode: Bool = false,
			 filterSelection: Int = 0,
			 userInputNotifications: Decimal = 0) {
		self.client = client
		self.isSearchMode = isSearchMode
		self.filterSelection = filterSelection
		self.userInputNotifications = userInputNotifications
		self.persistence = UserDefaults.group ?? UserDefaults.standard
		self.model = model
		self.input = input
		self.inputFID = Int(input) ?? 0
		
		setupListeners()
	}
	
	func claimMoxie() {
		
	}
	
	func updateNotificationOption(_ option: NotificationOption) {
		if selectedNotificationOptions.contains(option)  {
			selectedNotificationOptions.removeAll(where: {
				$0 == option
			})
		} else {
			selectedNotificationOptions.append(option)
		}
	}
	
	func setupListeners() {
		$selectedNotificationOptions
			.removeDuplicates()
			.sink { [weak self] options in
				self?.notify()
			}
			.store(in: &subscriptions)

		$error
			.sink { _ in }
			.store(in: &subscriptions)
		
		$filterSelection
			.dropFirst()
			.receive(on: DispatchQueue.main)
			.handleEvents(receiveRequest: { _ in
				self.inFlightTask?.cancel()
			})
			.debounce(for: .seconds(0.25), scheduler: RunLoop.main)
			.sink { [weak self] value in
				guard let self = self else {
					return
				}
				inFlightTask = Task {
					try await self.fetchStats(filter: MoxieFilter(rawValue: value) ?? .today)
				}
			}
			.store(in: &subscriptions)
		
		Publishers.CombineLatest3($inputFID, $filterSelection, $model)
			.dropFirst()
			.removeDuplicates { (previous, current) in
				return previous.0 == current.0 && // Compare inputFID
				previous.1 == current.1 && // Compare filterSelection
				previous.2 == current.2    // Compare model
			}
			.receive(on: DispatchQueue.main)
			.handleEvents(receiveRequest: { _ in
				self.inFlightTask?.cancel()
			})
			.debounce(for: .seconds(1.25), scheduler: RunLoop.main)
			.sink { [weak self] newInput, newFilter, newModel in
				guard let self = self, newInput > 0 else {
					return
				}
				if newInput.description != newModel.entityID {
					inFlightTask = Task {
						try await self.fetchStats(filter: MoxieFilter(rawValue: newFilter) ?? .today)
					}
				}
				
			}
			.store(in: &subscriptions)
				
		$model
			.receive(on: DispatchQueue.main)
			.filter({ Int($0.entityID) ?? 0 > 0 })
			.sink {
				self.input = $0.entityID
			}
			.store(in: &subscriptions)
		
		$model
			.receive(on: DispatchQueue.main)
			.compactMap({ $0.moxieClaimTotals.first })
			.map({ $0.availableClaimAmount * self.price })
			.sink { [weak self] in
				self?.dollarValueMoxie = $0
			}
			.store(in: &subscriptions)
		
		$model
			.receive(on: DispatchQueue.main)
			.tryMap { model in
				let encoder = CustomDecoderAndEncoder.encoder
				let encodedData = try encoder.encode(model)
				return encodedData
			}
			.catch { error -> Just<Data?> in
				return Just(nil) // You can choose how to handle errors, here we're returning nil
			}
			.compactMap { $0 }
			.sink { _ in
			}
			.store(in: &subscriptions)
		
		$price
			.removeDuplicates()
			.sink { [weak self] in
				self?.dollarValueMoxie = $0 * (self?.model.moxieClaimTotals.first?.availableClaimAmount ?? 0)
			}
			.store(in: &subscriptions)
	}
	
	func saveCustomMoxieInput() {
		guard let group = UserDefaults.group else {
			return
		}
		group.setValue(moxieChangeText, forKey: "userInputNotifications")
		userInputNotifications = Decimal(string: moxieChangeText) ?? 0
	}
	
	func onSubmitSearch() {
		let decimalCharacters = CharacterSet.decimalDigits
		let isNumber = input.rangeOfCharacter(from: decimalCharacters)
		
		if isNumber != nil {
			self.inputFID = Int(input)!
			self.isSearchMode = false
		} else {
			self.error = MoxieError.message("Please enter a number")
		}
	}
	
	func fetchPrice() async throws {
		do {
			price = try await client.fetchPrice()
		} catch {
			price = 0
		}
	}
	
	func fetchStats(filter: MoxieFilter) async throws {
		do {
			isLoading = true
			
			let newModel = try await client.fetchMoxieStats(userFID: inputFID, filter: filter)
			self.model = newModel
			self.error = nil
			self.inFlightTask = nil
			
			isLoading = false
		} catch {
			if error.localizedDescription != "Invalid" && error.localizedDescription != "cancelled" {
				self.error = MoxieError.message(error.localizedDescription)
			}
			isLoading = false
			self.model = .noop
			self.inFlightTask = nil
		}
	}
	
	func onAppear() async {
		do {
			if inputFID != 0 {
				let newModel = try await client.fetchMoxieStats(userFID: inputFID, filter: MoxieFilter(rawValue: filterSelection) ?? .today)
				self.model = newModel
				checkAndNotify(newModel: newModel, userInput: userInputNotifications)
				
				WidgetCenter.shared.reloadAllTimelines()
			}
		} catch {
			self.error = error
		}
	}
	
	func checkAndNotify(newModel: MoxieModel, userInput: Decimal) {
		let currentEarnings = model.allEarningsAmount
		let newAmount = newModel.allEarningsAmount
		
		let delta = newAmount - currentEarnings
		
		guard delta > 0 && userInput > 0 else {
			return
		}
		
		if delta >= userInput {
			let content = UNMutableNotificationContent()
			content.title = "$MOXIE earnings"
			content.body = "Congrats! Your Moxie earnings have now reached \(newAmount.formatted(.number.precision(.fractionLength(2)))). Check out your latest gains and keep the momentum going! 🚀"
			content.sound = .default
			
			let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
			let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
			
			UNUserNotificationCenter.current().add(request) { error in
				if let error = error {
					print("Failed to schedule notification: \(error.localizedDescription)")
				}
			}
		}
	}
	
	func removeAllScheduledNotifications() {
		persistence.removeObject(forKey: "notificationOptions")
		selectedNotificationOptions.removeAll()

		UNUserNotificationCenter.current().removeAllDeliveredNotifications()
		UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
	}
	
	func notify() {
		let content = UNMutableNotificationContent()
		content.title = "$MOXIE earnings"
		content.body = "\(model.allEarningsAmount.formatted(.number.precision(.fractionLength(2))))"
		content.sound = .default
		
		selectedNotificationOptions.forEach { option in
			let interval: TimeInterval
			switch option {
			case .hour:
				interval = 3600
			case .week:
				interval = 3600 * 24 * 7
			case .month:
				interval = 3600 * 24 * 7 * 30
			default:
				interval = 0
			}
			
			if interval > 0 {
				let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: true)
				let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
				
				UNUserNotificationCenter.current().add(request) { error in
					if let error = error {
						print("Failed to schedule notification: \(error.localizedDescription)")
					}
				}
			} else {
				let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
				let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
				
				UNUserNotificationCenter.current().add(request) { error in
					if let error = error {
						print("Failed to schedule notification: \(error.localizedDescription)")
					}
				}
			}
		}
	}
}

extension MoxieViewModel {
	func timeAgoDisplay() {
		let formatter = RelativeDateTimeFormatter()
		formatter.unitsStyle = .full
		let string = formatter.localizedString(for: model.endTimestamp, relativeTo: .now)
		
		self.timeAgo = string
	}
}
