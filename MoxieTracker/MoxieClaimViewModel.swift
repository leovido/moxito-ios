import SwiftUI
import MoxieLib
import Combine
import Sentry

enum ClaimAction: Hashable {
	case initiateClaim
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
	@Published var inFlightTasks: [String: Task<Void, Never>] = [:]
	private var timerCancellable: AnyCancellable?

	public let actions: PassthroughSubject<ClaimAction, Never>

	@Published var willPlayAnimationNumbers: Bool = false

	@Published var isClaimRequested: Bool = true
	@Published var moxieClaimModel: MoxieClaimModel?
	@Published var moxieClaimStatus: MoxieClaimStatus?
	@Published var isClaimSuccess: Bool = false
	@Published var isClaimAlertShowing: Bool = false
	@Published var isClaimDialogShowing: Bool = false
	
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
					isClaimAlertShowing = true
					selectedWallet = wallet
				case .checkClaimStatus(let fid, let transactionId):
					inFlightTasks[RequestType.checkClaimStatus.rawValue] = Task {
						await self.requestClaimStatus(fid: fid, transactionId: transactionId)
					}
					break
				case .claimRewards(let fid, let wallet):
					inFlightTasks[RequestType.claimRewards.rawValue] = Task {
						await self.claimMoxie(fid: fid, selectedWallet: wallet)
					}
					break
				case .initiateClaim:
					isClaimDialogShowing.toggle()
					break
				case .dismissClaimAlert:
					moxieClaimModel = nil
					moxieClaimStatus = nil
					isClaimRequested = false

					willPlayAnimationNumbers = true
					
					isClaimSuccess = true
					
					break
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
