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
final class MoxieViewModel: ObservableObject {
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
	
	let client: MoxieProvider
	
	private(set) var subscriptions: Set<AnyCancellable> = []
	
	init(input: String = "",
			 model: MoxieModel = .noop,
			 isLoading: Bool = false,
			 client: MoxieProvider,
			 isSearchMode: Bool = false,
			 filterSelection: Int = 0,
			 userInputNotifications: Decimal = 0) {
		self.client = client
		self.isSearchMode = isSearchMode
		self.filterSelection = filterSelection
		
		if let savedData = UserDefaults.standard.data(forKey: "notificationOptions") {
			do {
				let notificationOptions = try JSONDecoder().decode([NotificationOption].self, from: savedData)
				self.selectedNotificationOptions = notificationOptions
			} catch {
				print("Failed to decode notification options: \(error.localizedDescription)")
			}
		}
		
		if let data = UserDefaults.standard.data(forKey: "moxieModel"),
			 let decodedModel = try? CustomDecoderAndEncoder.decoder.decode(MoxieModel.self, from: data) {
			self.model = decodedModel
			self.input = input.isEmpty ? decodedModel.entityID : input
		} else {
			self.model = model
			self.input = input
		}
		
		if let decodedUserInputNotifications = UserDefaults.standard.string(forKey: "userInputNotifications") {
			let decimalValue = Decimal(string: decodedUserInputNotifications) ?? 100000
			 self.userInputNotifications = decimalValue
		} else {
			self.userInputNotifications = userInputNotifications
		}
		
		setupListeners()
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
				let encoder = CustomDecoderAndEncoder.encoder
				let encodedData = try! encoder.encode(options)
				
				UserDefaults.standard.setValue(encodedData, forKey: "notificationOptions")
				
				self?.notify()
			}
			.store(in: &subscriptions)

		$error
			.sink { _ in }
			.store(in: &subscriptions)
		
		$input
			.removeDuplicates()
			.sink { newValue in
				self.inputFID = Int(newValue) ?? 0
			}
			.store(in: &subscriptions)
		
		Publishers.CombineLatest($inputFID, $filterSelection)
			.dropFirst() // Skip the first emitted value
			.removeDuplicates { $0 == $1 } // Optional: Avoid triggering for the same values
			.debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
			.receive(on: DispatchQueue.main)
			.sink { [weak self] value in
				guard let self = self, value.0 != 0 else {
					return
				}
				Task {
					try await self.fetchStats(filter: MoxieFilter(rawValue: value.1) ?? .today)
				}
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
			.removeDuplicates()
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
			.sink { encodedData in
				if !self.isSearchMode {
					UserDefaults.standard.set(encodedData, forKey: "moxieModel")
				}
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
		UserDefaults.standard.setValue(moxieChangeText, forKey: "userInputNotifications")
		self.userInputNotifications = Decimal(string: moxieChangeText) ?? 0
	}
	
	func fetchPrice() async throws {
		do {
			price = try await client.fetchPrice()
		} catch {
			self.error = error
			price = 0
		}
	}
	
	func fetchStats(filter: MoxieFilter) async throws {
		do {
			isLoading = true
			
			let newModel = try await client.fetchMoxieStats(userFID: inputFID, filter: filter)
			self.model = newModel
			checkAndNotify(newModel: newModel, userInput: userInputNotifications)
			
			isLoading = false
		} catch {
			self.error = error
			self.model = .noop
			isLoading = false
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
		UserDefaults.standard.removeObject(forKey: "notificationOptions")
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
