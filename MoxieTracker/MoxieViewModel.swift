import SwiftUI
import WidgetKit
import MoxieLib
import Combine
import Sentry
#if canImport(ActivityKit)
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
	private var currentActivity: Activity<MoxieActivityAttributes>?

	var inFlightTask: Task<Void, Error>?

	@Published var persistence: UserDefaults
	@Published var wallets: [String] = []
	@Published var fansCount: String = ""

	@Published var input: String
	@Published var confettiCounter: Int = 0
	@Published var model: MoxieModel

	@Published var isLoading: Bool = false
	@Published var price: Decimal = 0
	@Published var timeAgo: String = ""
	@Published var userInputNotifications: Decimal
	@Published var isSearchMode: Bool
	@Published var moxieChangeText: String = ""
	@Published var isNotificationSheetPresented: Bool = false
	@Published var moxieSplits: MoxieSplits = .placeholder

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

		self.userInputNotifications = Decimal(string: persistence.string(forKey: "userInputNotificationsData") ?? "0") ?? 0

		setupListeners()

		startMoxieActivity()
	}

	func startMoxieActivity() {
		if model.entityID != "" {
			if ActivityAuthorizationInfo().areActivitiesEnabled {
				let attributes = MoxieActivityAttributes()
				let contentState = MoxieActivityAttributes.ContentState(
					dailyMoxie: model.allEarningsAmount.formatted(.number.precision(.fractionLength(0))),
					dailyUSD: formattedDollarValue(dollarValue: model.allEarningsAmount * price),
					claimableMoxie: model.moxieClaimTotals[0].availableClaimAmount.formatted(.number.precision(.fractionLength(0))),
					claimableUSD: formattedDollarValue(dollarValue: model.moxieClaimTotals[0].availableClaimAmount * price),
					username: model.socials[0].profileDisplayName,
					fid: model.entityID,
					imageURL: model.socials[0].profileImage)
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
			Publishers.CombineLatest3($inputFID, $filterSelection, $model)
				.dropFirst()
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
		}

		$model
			.receive(on: DispatchQueue.main)
			.print()
			.filter({ Int($0.entityID) ?? 0 > 0 })
			.sink {
				self.input = $0.entityID
				self.wallets = $0.socials.first?.connectedAddresses
					.filter({$0.blockchain == "ethereum"})
					.map({ $0.address }) ?? []
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

	func updateDeliveryActivity(newModel: MoxieModel) {
		if newModel.entityID != "" {
			Task {
				for activity in Activity<MoxieActivityAttributes>.activities {
					let updatedContentState = MoxieActivityAttributes.ContentState(
						dailyMoxie: newModel.allEarningsAmount.formatted(.number.precision(.fractionLength(0))),
						dailyUSD: formattedDollarValue(dollarValue: newModel.allEarningsAmount * self.price),
						claimableMoxie: newModel.moxieClaimTotals.first?.availableClaimAmount.formatted(.number.precision(.fractionLength(0))) ?? "0",
						claimableUSD: formattedDollarValue(dollarValue: newModel.moxieClaimTotals.first?.availableClaimAmount ?? 0 * self.price),
						username: model.socials.first?.profileDisplayName ?? "",
						fid: model.entityID,
						imageURL: model.socials.first?.profileImage ?? ""
					)

					await activity.update(using: updatedContentState)
				}
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
				if error.localizedDescription == "The data couldn’t be read because it is missing." {
//					self.error = MoxieError.message("User does not have Moxie pass")
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
		persistence.removeObject(forKey: "notificationOptions")
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
