import SwiftUI
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

	@Published var input = ""
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
	
	@Published var inputFID: Int = -1

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
		
		$input
			.removeDuplicates()
			.sink { newValue in
				let decimalCharacters = CharacterSet.decimalDigits
				let decimalRange = newValue.rangeOfCharacter(from: decimalCharacters)

				if decimalRange != nil {
					self.inputFID = Int(newValue) ?? 0
					self.error = nil
				} else {
					self.error = MoxieError.message("Please enter a number")
				}
			}
			.store(in: &subscriptions)
		
		Publishers.CombineLatest($inputFID, $filterSelection)
			.dropFirst()
			.removeDuplicates { $0 == $1 }
			.receive(on: DispatchQueue.main)
			.handleEvents(receiveRequest: { _ in
				self.inFlightTask?.cancel()
			})
			.debounce(for: .seconds(0.5), scheduler: RunLoop.main)
			.sink { [weak self] value in
				guard let self = self, value.0 != 0 else {
					return
				}
				inFlightTask = Task {
					try await self.fetchStats(filter: MoxieFilter(rawValue: value.1) ?? .today)
				}
			}
			.store(in: &subscriptions)
				
		$model
			.receive(on: DispatchQueue.main)
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
				print("Failed to encode model: \(error.localizedDescription)")
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
		self.userInputNotifications = Decimal(string: moxieChangeText) ?? 0
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
			self.error = error
			self.model = .noop
			isLoading = false
		}
	}
	
	func onAppear() async {
		do {
			let newModel = try await client.fetchMoxieStats(userFID: inputFID, filter: MoxieFilter(rawValue: filterSelection) ?? .today)
			self.model = newModel
			checkAndNotify(newModel: newModel, userInput: userInputNotifications)
		} catch {
			self.error = error
		}
	}
	
	func checkAndNotify(newModel: MoxieModel, userInput: Decimal) {
		let currentEarnings = model.allEarningsAmount
		let newAmount = newModel.allEarningsAmount
		
		let delta = newAmount - currentEarnings
		
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
