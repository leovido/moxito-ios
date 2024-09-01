import SwiftUI
import MoxieLib
import Combine

@MainActor
final class MoxieViewModel: ObservableObject {
	@Published var input = ""
	@Published var model: MoxieModel
	@Published var isLoading: Bool = false
	@Published var price: Decimal = 0
	@Published var timeAgo: String = ""
	@Published var userInputNotifications: Decimal = 0
	@Published var moxieChangeText: String = ""
	
	@Published var filterSelection: Int = 0
	@Published var error: Error?

	@Published var dollarValueMoxie: Decimal = 0
	
	@Published var inputFID: Int = -1
	
	let client: MoxieProvider
	
	private(set) var subscriptions: Set<AnyCancellable> = []
	
	init(input: String = "",
			 model: MoxieModel = .noop,
			 client: MoxieProvider) {
		self.input = input
		self.client = client
		
		if let data = UserDefaults.standard.data(forKey: "moxieModel"),
			 let decodedModel = try? CustomDecoderAndEncoder.decoder.decode(MoxieModel.self, from: data) {
			self.model = decodedModel
			self.input = decodedModel.entityID
		} else {
			self.model = model
		}
		
		if let decodedUserInputNotifications = UserDefaults.standard.string(forKey: "userInputNotifications"),
			 let decimalValue = Decimal(string: decodedUserInputNotifications) {
			 self.userInputNotifications = decimalValue
		} else {
			self.userInputNotifications = 0
		}
		
		$filterSelection
			.receive(on: DispatchQueue.main)
			.sink { [weak self] value in
				guard let self = self else {
					return
				}
				Task {
					try await self.fetchStats()
				}
			}
			.store(in: &subscriptions)
		
		$input
			.sink { newValue in
				self.inputFID = Int(newValue) ?? 0
			}
			.store(in: &subscriptions)
		
		$inputFID
			.receive(on: DispatchQueue.main)
			.debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
			.sink { [weak self] value in
				guard let self = self, value != 0 else {
					return
				}
				Task {
					try await self.fetchStats()
				}
			}
			.store(in: &subscriptions)
		
		$moxieChangeText
			.receive(on: DispatchQueue.main)
			.sink {
				UserDefaults.standard.setValue($0, forKey: "userInputNotifications")
			}
			.store(in: &subscriptions)

		$model
			.receive(on: DispatchQueue.main)
			.compactMap({ $0.moxieClaimTotals.first })
			.map({ $0.claimedAmount * self.price })
			.sink { [weak self] in
				self?.dollarValueMoxie = $0
				
			}
			.store(in: &subscriptions)
		
		$model
			.receive(on: DispatchQueue.main)
			.sink {
				let encoder = CustomDecoderAndEncoder.encoder
				
				let encodedData = try! encoder.encode($0)
				UserDefaults.standard.set(encodedData, forKey: "moxieModel")
			}
			.store(in: &subscriptions)
				
		$price
			.sink { [weak self] in
				self?.dollarValueMoxie = $0 * (self?.model.moxieClaimTotals.first?.claimedAmount ?? 0)
			}
			.store(in: &subscriptions)
	}
	
	func fetchPrice() async throws {
		price = try await client.fetchPrice()
	}
	
	func fetchStats() async throws {
		do {
			isLoading = true
			
			let newModel = try await client.fetchMoxieStats(userFID: inputFID, filter: .today)
			checkAndNotify(newModel: newModel, userInput: userInputNotifications)
			
			isLoading = false
		} catch {
			self.error = error
			isLoading = false
		}
	}
	
	func checkAndNotify(newModel: MoxieModel, userInput: Decimal) {
		let currentEarnings = model.allEarningsAmount
		let newAmount = newModel.allEarningsAmount
		
		let delta = newAmount - currentEarnings
		
		if delta > userInput {
			let content = UNMutableNotificationContent()
			content.title = "$MOXIE earnings"
			content.body = "Congrats! Your Moxie earnings have now reached \(newAmount). Check out your latest gains and keep the momentum going! 🚀"
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
}

extension MoxieViewModel {
	func timeAgoDisplay() {
		let formatter = RelativeDateTimeFormatter()
		formatter.unitsStyle = .full
		let string = formatter.localizedString(for: model.endTimestamp, relativeTo: .now)
		
		self.timeAgo = string
	}
}
