import SwiftUI
import MoxieLib
import Combine
import Sentry

enum ClaimAction: Hashable {
	case initiateClaim(Tab)
	case claimRewards(fid: String, wallet: String)
	case checkClaimStatus(fid: String, transactionId: String)
	case selectedWallet(String)
	case dismissClaimAlert
}

enum RequestType: String, Hashable {
	case checkClaimStatus
	case claimRewards
}

@MainActor
final class MoxieClaimViewModel: ObservableObject, Observable {
	static let shared = MoxieClaimViewModel()

	@Published var inFlightTasks: [String: Task<Void, Never>] = [:]
	private var timerCancellable: AnyCancellable?

	public let actions: PassthroughSubject<ClaimAction, Never>

	@Published var willPlayAnimationNumbers: Bool = false

	@Published var number: Decimal = 0
	@Published var progress: Double = 0
	@Published var timer: Timer?
	@Published var timerProgress: Timer?

	@Published var isClaimRequested: Bool = false
	@Published var moxieClaimModel: MoxieClaimModel?
	@Published var moxieClaimStatus: MoxieClaimStatus?
	@Published var isClaimSuccess: Bool = false
	@Published var isClaimAlertShowing: Bool = false
	@Published var isClaimDialogShowing: Bool = false
	@Published var isClaimDialogShowingRewards: Bool = false

	@Published var selectedWallet: String = ""
	@Published var selectedWalletDisplay: String = ""

	@Published var isLoading: Bool = false
	@Published var isError: Error?

	private let client: MoxieProvider

	private(set) var subscriptions: Set<AnyCancellable> = []

	init(moxieClaimStatus: MoxieClaimStatus? = nil,
			 moxieClaimModel: MoxieClaimModel? = nil,
			 client: MoxieProvider = MoxieClient()) {
		self.client = client
		self.moxieClaimModel = moxieClaimModel
		self.moxieClaimStatus = moxieClaimStatus

		self.actions = PassthroughSubject()

		setupListeners()
	}

	func setupListeners() {
		let sharedWillPlayPub = $willPlayAnimationNumbers
			.filter({ $0 })

		sharedWillPlayPub
			.debounce(for: .seconds(5), scheduler: RunLoop.main)
			.sink { [weak self] _ in
				self?.willPlayAnimationNumbers = false
			}
			.store(in: &subscriptions)

		$moxieClaimModel
			.filter({ $0 != nil })
			.debounce(for: .seconds(1), scheduler: RunLoop.main)
			.sink { [weak self] claimModel in
				self?.actions.send(.checkClaimStatus(fid: claimModel?.fid ?? "0", transactionId: claimModel?.transactionID ?? ""))
			}
			.store(in: &subscriptions)

		let sharedActionsPublisher = actions.share()

		sharedActionsPublisher
			.sink { [weak self] newAction in
				guard let self = self else {
					return
				}
				switch newAction {
				case .selectedWallet(let wallet):
					isClaimDialogShowing = false
					isClaimDialogShowingRewards = false
					isClaimAlertShowing = true
					selectedWallet = wallet
				case .checkClaimStatus(let fid, let transactionId):
					inFlightTasks[RequestType.checkClaimStatus.rawValue] = Task {
						await self.requestClaimStatus(fid: fid, transactionId: transactionId)
					}
				case .claimRewards(let fid, let wallet):
					inFlightTasks[RequestType.claimRewards.rawValue] = Task {
						await self.claimMoxie(fid: fid, selectedWallet: wallet)
					}
				case .initiateClaim(let tab):
					if tab == .fitness {
						isClaimDialogShowingRewards.toggle()
					} else {
						isClaimDialogShowing.toggle()
					}
				case .dismissClaimAlert:
					moxieClaimModel = nil
					moxieClaimStatus = nil
					isClaimRequested = false

					willPlayAnimationNumbers = true

					isClaimSuccess = true
				}
			}
			.store(in: &subscriptions)

		$selectedWallet
			.removeDuplicates()
			.sink { [weak self] wallet in
				self?.selectedWalletDisplay = "\(wallet.prefix(4))...\(wallet.suffix(4))"
			}
			.store(in: &subscriptions)
	}

	private func claimMoxie(fid: String, selectedWallet: String) async {
		do {
			isClaimRequested = true
			isLoading = true
			moxieClaimModel = try await client.processClaim(userFID: fid,
																				wallet: selectedWallet)
			isLoading = false
			inFlightTasks[RequestType.claimRewards.rawValue] = nil
		} catch {
			isLoading = false
			isError = MoxieError.message(error.localizedDescription)
			inFlightTasks[RequestType.claimRewards.rawValue] = nil
			SentrySDK.capture(error: error)
		}
	}

	private func requestClaimStatus(fid: String, transactionId: String) async {
		do {
			isLoading = true
			moxieClaimStatus = try await self.client.fetchClaimStatus(fid: fid, transactionId: transactionId)
			inFlightTasks[RequestType.checkClaimStatus.rawValue] = nil
		} catch {
			isLoading = false
			isError = MoxieError.message(error.localizedDescription)
			inFlightTasks[RequestType.checkClaimStatus.rawValue] = nil
			SentrySDK.capture(error: error)
		}
	}
}

extension MoxieClaimViewModel {
	func startProgressTimer() {
		let totalDuration: TimeInterval = 5.0 // Total time for progress to complete (15 seconds)
		let updateInterval: TimeInterval = 0.1 // Interval at which to update the progress

		let progressIncrement: CGFloat = CGFloat(updateInterval / totalDuration)
		timerProgress = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { _ in
			if self.progress < 1.0 {
				self.progress += Double(progressIncrement)
			} else {
				self.timerProgress?.invalidate()
			}
		}
	}

	// Stop the timer if the view disappears
	func stopProgressTimer() {
		timerProgress?.invalidate()
		timerProgress = nil
	}

	func startCountdown() {
		let totalDuration: Decimal = 3.0 // Total countdown time in seconds
		let interval: TimeInterval = 0.01 // Fixed time interval for smooth animation
		let steps = totalDuration / Decimal(interval) // Total number of steps
		let decrementAmount: Decimal = number / steps // Amount to decrement per step

		// Schedule the timer
		timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
			if self.number > 0 {
				withAnimation(.linear(duration: interval)) {
					self.number -= decrementAmount
				}
			} else {
				self.timer?.invalidate()
				self.number = 0
			}
		}
	}
}
