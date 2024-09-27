import SwiftUI
import MoxieLib
import Combine
import Sentry

enum ClaimAction: Hashable {
	case initiateClaim
	case claimRewards(String)
	case checkClaimStatus(transactionId: String)
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

	@Published var fid: String = ""
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
				case .checkClaimStatus:
					inFlightTasks[RequestType.checkClaimStatus.rawValue] = Task {
						await self.requestClaimStatus()
					}
					break
				case .claimRewards(let wallet):
					inFlightTasks[RequestType.claimRewards.rawValue] = Task {
						await self.claimMoxie(selectedWallet: wallet)
					}
					break
				case .initiateClaim:
					isClaimDialogShowing.toggle()
					break
				case .dismissClaimAlert:
					self.isClaimAlertShowing = false
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
		
		let sharedPub = $moxieClaimStatus
			.removeDuplicates()
			.share()
	
		sharedPub
			.filter({ $0?.transactionStatus == nil || $0?.transactionStatus == .SUCCESS })
			.sink { [weak self] value in
				self?.isLoading = false
			}
			.store(in: &subscriptions)
		
		$isClaimAlertShowing
			.removeDuplicates()
			.filter({ !$0 })
			.sink { [weak self] _ in
				guard let self = self else {
					return
				}
//				self.willPlayAnimationNumbers = true
				
//				Task {
//					try await self.fetchStats(filter: MoxieFilter(rawValue: self.filterSelection) ?? .today)
//				}
			}
			.store(in: &subscriptions)
	}
	
	private func claimMoxie(selectedWallet: String) async {
		do {
			isLoading = true
			moxieClaimModel = try await client.processClaim(userFID: fid.description,
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
	
	private func requestClaimStatus() async {
		do {
			isLoading = true
			moxieClaimStatus = try await self.client.fetchClaimStatus(fid: self.fid, transactionId: moxieClaimStatus?.transactionID ?? "")
			inFlightTasks[RequestType.checkClaimStatus.rawValue] = nil
		} catch {
			isLoading = false
			isError = MoxieError.message(error.localizedDescription)
			inFlightTasks[RequestType.checkClaimStatus.rawValue] = nil
			SentrySDK.capture(error: error)
		}
	}
}
