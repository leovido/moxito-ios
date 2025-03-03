import SwiftUI
import WidgetKit
import MoxieLib
import Combine
import Sentry
#if os(iOS)
import ActivityKit
#endif

enum NotificationOption: Codable, Hashable, CaseIterable {
	static let allCases: [NotificationOption] = [.hour, .week, .month]

	case hour
	case week
	case month
}

@MainActor
final class MoxieViewModel: ObservableObject, Observable {
	static let shared = MoxieViewModel()
#if os(iOS)
	private var currentActivity: Activity<MoxieActivityAttributes>?
#endif

	var inFlightTask: Task<Void, Error>?

	@Published var persistence: UserDefaults
	@Published var wallets: [String] = []
	@Published var fansCount: String = ""

	@Published var input: String
	@Published var confettiCounter: Int = 0
	@Published var model: MoxieModel

	@Published var isLoading: Bool = false
	@Published var price: Decimal = 0
	@Published var totalPoolRewards: Decimal = 0

	@Published var timeAgo: String = ""
	@Published var userInputNotifications: Decimal
	@Published var isSearchMode: Bool
	@Published var moxieChangeText: String = ""
	@Published var isNotificationSheetPresented: Bool = false
	@Published var moxieSplits: MoxieSplits = .placeholder
	@Published var availableClaimAmountFormatted: String = ""

	@Published var selectedNotificationOptions: [NotificationOption] = []

	@Published var filterSelection: Int
	@Published var error: Error?

	@Published var dollarValueMoxie: Decimal = 0

	@Published var inputFID: Int

	private let client: MoxieProvider
	private let notificationService: NotificationProvider

	private(set) var subscriptions: Set<AnyCancellable> = []

	init(input: String = "",
			 model: MoxieModel = .noop,
			 isLoading: Bool = false,
			 client: MoxieProvider = MoxieClient(),
			 isSearchMode: Bool = false,
			 filterSelection: Int = 0,
			 userInputNotifications: Decimal = 0,
			 availableClaimAmountFormatted: String = "",
			 notificationService: NotificationProvider = NotificationService()) {
		self.client = client
		self.isSearchMode = isSearchMode
		self.filterSelection = filterSelection
		self.userInputNotifications = userInputNotifications
		self.persistence = UserDefaults.group ?? UserDefaults.standard
		self.model = model
		self.input = input
		self.inputFID = Int(input) ?? 0
		self.notificationService = notificationService

		self.userInputNotifications = Decimal(string: persistence.string(forKey: "userInputNotificationsData") ?? "0") ?? 0
		self.availableClaimAmountFormatted = ""
		setupListeners()

//		startMoxieActivity()
	}

	func startMoxieActivity() {
		if ActivityAuthorizationInfo().areActivitiesEnabled {
			let attributes = MoxieActivityAttributes()
			let contentState = MoxieActivityAttributes.ContentState(
				dailyMoxie: model.allEarningsAmount.formatted(.number.precision(.fractionLength(0))),
				dailyUSD: formattedDollarValue(dollarValue: model.allEarningsAmount * price),
				claimableMoxie: model.moxieClaimTotals[0].availableClaimAmount.formatted(.number.precision(.fractionLength(0))),
				claimableUSD: formattedDollarValue(dollarValue: model.moxieClaimTotals[0].availableClaimAmount * price),
				username: model.socials.profileDisplayName,
				fid: model.entityID,
				imageURL: model.socials.profileImage)
			do {
				let activity = try Activity<MoxieActivityAttributes>.request(
					attributes: attributes,
					content: .init(state: contentState, staleDate: nil),
					pushType: nil
				)
				currentActivity = activity
			} catch {
				print("Error starting activity: \(error.localizedDescription)")
			}
		}
	}

	func updateNotificationOption(_ option: NotificationOption) {
		if selectedNotificationOptions.contains(option) {
			selectedNotificationOptions.removeAll(where: {
				$0 == option
			})
		} else {
			selectedNotificationOptions.append(option)
		}
	}

	func setupListeners() {
		$model
			.compactMap(\.moxieClaimTotals)
			.compactMap({ $0.first })
			.map(\.availableClaimAmount)
			.sink { [weak self] availableClaimAmount in
				self?.availableClaimAmountFormatted = availableClaimAmount.formatted(.number.precision(.fractionLength(0)))
			}
			.store(in: &subscriptions)

		$selectedNotificationOptions
			.removeDuplicates()
			.sink { [weak self] _ in
				self?.removeAllScheduledNotifications()
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

		if isSearchMode {
			Publishers.CombineLatest3($inputFID, $filterSelection, $model)
				.removeDuplicates { (previous, current) in
					return previous.0 == current.0 &&
					previous.1 == current.1 &&
					previous.2 == current.2
				}
				.receive(on: DispatchQueue.main)
				.handleEvents(receiveRequest: { _ in
					self.inFlightTask?.cancel()
				})
				.debounce(for: .seconds(0.25), scheduler: RunLoop.main)
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
		} else {
			Publishers.CombineLatest($inputFID, $filterSelection)
				.dropFirst()
				.removeDuplicates { (previous, current) in
					return previous.0 == current.0 &&
					previous.1 == current.1
				}
				.print("CombineLatest3")
				.receive(on: DispatchQueue.main)
				.handleEvents(receiveRequest: { _ in
					self.inFlightTask?.cancel()
				})
				.debounce(for: .seconds(0.25), scheduler: DispatchQueue.main)
				.sink { [weak self] newInput, newFilter in
					guard let self = self, newInput > 0 else {
						return
					}
					inFlightTask = Task {
						try await self.fetchStats(filter: MoxieFilter(rawValue: newFilter) ?? .today)
					}
				}
				.store(in: &subscriptions)
		}

		$model
			.receive(on: DispatchQueue.main)
			.filter({ $0.entityID.isEmpty })
			.sink { [weak self] _ in
				guard let self else {
					return
				}
				Task {
					try await self.removeActivity()
				}
			}
			.store(in: &subscriptions)

		$model
			.receive(on: DispatchQueue.main)
			.filter({ Int($0.entityID) ?? 0 > 0 })
			.sink {
				self.input = $0.entityID
				self.wallets = $0.socials.connectedAddresses
					.filter({$0.blockchain == "ethereum"})
					.map({ $0.address })

				if self.currentActivity != nil {
					self.startMoxieActivity()
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
			.receive(on: DispatchQueue.main)
			.sink { [weak self] newModel in
				guard let self = self else {
					return
				}
				updateDeliveryActivity(newModel: newModel)
			}
			.store(in: &subscriptions)

		$price
			.removeDuplicates()
			.sink { [weak self] in
				guard let self = self else {
					return
				}
				self.dollarValueMoxie = $0 * (self.model.moxieClaimTotals.first?.availableClaimAmount ?? 0)
				self.updateDeliveryActivity(newModel: self.model)
			}
			.store(in: &subscriptions)
	}

	func removeActivity() async throws {
		await self.currentActivity?.end(ActivityContent(state: .init(dailyMoxie: "", dailyUSD: "", claimableMoxie: "", claimableUSD: "", username: "", fid: "", imageURL: ""), staleDate: nil), dismissalPolicy: .immediate)
		self.currentActivity = nil
	}

	func updateDeliveryActivity(newModel: MoxieModel) {
		guard price > 0 else { return }
		let claimable = newModel.moxieClaimTotals.first?.availableClaimAmount ?? 0
		let ttt = claimable * self.price

		if newModel.entityID != "" {
			Task {
				for activity in Activity<MoxieActivityAttributes>.activities {
					let updatedContentState = MoxieActivityAttributes.ContentState(
						dailyMoxie: newModel.allEarningsAmount.formatted(.number.precision(.fractionLength(0))),
						dailyUSD: formattedDollarValue(dollarValue: newModel.allEarningsAmount * self.price),
						claimableMoxie: newModel.moxieClaimTotals.first?.availableClaimAmount.formatted(.number.precision(.fractionLength(0))) ?? "0",
						claimableUSD: formattedDollarValue(dollarValue: ttt),
						username: model.socials.profileDisplayName,
						fid: model.entityID,
						imageURL: model.socials.profileImage
					)

					await activity.update(using: updatedContentState)
				}
			}
		} else {
			Task {
				try await self.removeActivity()
			}
		}
	}

	func saveCustomMoxieInput() {
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

	func fetchFansCount() async throws {
		do {
			let fansCountLocal = try await client.fetchFansCount(fid: input)

			fansCount = fansCountLocal.description
		} catch {
			fansCount = "0"
		}
	}

	func fetchPrice() async throws {
		do {
			price = try await client.fetchPrice()
		} catch {
			price = 0
		}
	}

	func fetchTotalPoolRewards() async throws {
		do {
			totalPoolRewards = try await client.fetchTotalPoolRewards()
		} catch {
			totalPoolRewards = 0
		}
	}

	func fetchStats(filter: MoxieFilter) async throws {
		do {
			isLoading = true

			let newModel = try await client.fetchMoxieStats(userFID: inputFID, filter: filter)
			self.model = newModel
			self.error = nil
			self.inFlightTask = nil

			self.isLoading = false
		} catch {
			self.isLoading = false
			self.inFlightTask = nil

			if error.localizedDescription != "Invalid" && error.localizedDescription != "cancelled" {
				if error.localizedDescription == "The data couldn't be read because it is missing." {
				} else {
					self.error = MoxieError.message(error.localizedDescription)
				}
			} else {
				self.error = MoxieError.message(error.localizedDescription)
			}
		}
	}

	func onAppear() async {
		do {
			if inputFID != 0 {
				let newModel = try await client.fetchMoxieStats(userFID: inputFID, filter: MoxieFilter(rawValue: filterSelection) ?? .today)
				self.model = newModel
				self.input = model.entityID
				checkAndNotify(newModel: newModel, userInput: userInputNotifications)

				try await fetchFansCount()
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

		if delta > userInput {
			let content = UNMutableNotificationContent()
			content.title = "$MOXIE earnings"
			content.body = "Congrats! Your Moxie earnings have now reached \(newAmount.formatted(.number.precision(.fractionLength(0)))). Check out your latest gains and keep the momentum going! 🚀"
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
//		persistence.removeObject(forKey: "notificationOptions")
		selectedNotificationOptions.removeAll()

		UNUserNotificationCenter.current().removeAllDeliveredNotifications()
		UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
	}

	func notify() {
		let content = UNMutableNotificationContent()
		content.title = "$MOXIE earnings"
		content.body = "\(model.allEarningsAmount.formatted(.number.precision(.fractionLength(0))))"
		content.sound = .default

		selectedNotificationOptions
			.forEach { option in
			let interval: TimeInterval
			switch option {
			case .hour:
				interval = 3600
			case .week:
				interval = 3600 * 24 * 7
			case .month:
				interval = 3600 * 24 * 7 * 30
			}

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

extension MoxieViewModel {
	func timeAgoDisplay() {
		let formatter = RelativeDateTimeFormatter()
		formatter.unitsStyle = .full
		let string = formatter.localizedString(for: model.endTimestamp, relativeTo: .now)

		self.timeAgo = string
	}
}
