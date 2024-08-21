import Foundation

public enum Endpoint {
	static let fartherEndpoint = "https://farther.social/api/v1/"
}

public enum FartherEndpoint: String {
	case tipsByFid = "public.user.byFid"
	case tipsByWallet = "public.user.byAddress"
}

public enum TipError: LocalizedError {
	case message(String)
}

public protocol TipProvider {
	func fetchFartherTips(forceRemote: Bool) async throws -> TipModel
}

public struct TipModel: Decodable {
	public var id: UUID
	public var fid: Int
	public var username: String
	public var displayName: String
	public var pfpUrl: String
	public var allowance: Int
	public var given: Int
	public var received: Int
	public var balance: String
	public var tipMin: Int
	public var rank: Int
	
	public init(id: UUID, fid: Int, username: String, displayName: String, pfpUrl: String, allowance: Int, given: Int, received: Int, balance: String, tipMin: Int, rank: Int) {
		self.id = id
		self.fid = fid
		self.username = username
		self.displayName = displayName
		self.pfpUrl = pfpUrl
		self.allowance = allowance
		self.given = given
		self.received = received
		self.balance = balance
		self.tipMin = tipMin
		self.rank = rank
	}
}

extension TipModel {
	public static let placeholder: TipModel = .init(
		id: UUID(),
		fid: 203666,
		username: "Leovido🎩✨",
		displayName: "@leovido.eth",
		pfpUrl: "https://imagedelivery.net/BXluQx4ige9GuW0Ia56BHw/883cecce-71a6-4f84-68da-426bedf00e00/rectcrop3",
		allowance: 4973,
		given: 2000,
		received: 0,
		balance: "335469188489011551627074",
		tipMin: 200,
		rank: 21
	)
}

public final class TipClient: TipProvider {
	private let session: URLSession = .init(configuration: .default, delegate: nil, delegateQueue: nil)
	private let cacheManager: CacheManager
	
	public init(cacheManager: CacheManager = .init()) {
		self.cacheManager = cacheManager
	}
	
	public func fetchFartherTips(forceRemote: Bool) async throws -> TipModel {
		var url = URL(string: Endpoint.fartherEndpoint)!
		url.append(path: FartherEndpoint.tipsByFid.rawValue)
		
		guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
			throw TipError.message("Invalid")
		}
		
		let query = """
		{
			"fid": 203666
		}
		"""
		components.queryItems = [
			.init(name: "input", value: query)
		]
		
		var request = URLRequest(url: components.url!)
//		request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData // Fresh fetch, ignoring everything
//		request.cachePolicy = .reloadRevalidatingCacheData // server needs to confirm local cache in order to use
//		request.cachePolicy = .reloadIgnoringLocalCacheData // load from originating source. Use when downloading or streaming
//		request.cachePolicy = .reloadIgnoringCacheData
		request.cachePolicy = forceRemote ? .reloadIgnoringLocalAndRemoteCacheData : .returnCacheDataDontLoad // offline mode. If no cache, no attempt to load from originating source
//		request.cachePolicy = .returnCacheDataElseLoad // load cache, else load from remote
		
		let data = try await cacheManager.fetchData(for: request, forceRemote: forceRemote)
		let model = try JSONDecoder().decode(FartherTipModel.self, from: data)
		
		return TipModel(id: UUID(),
										fid: model.result?.data?.fid ?? 0,
										username: model.result?.data?.username ?? "",
										displayName: model.result?.data?.displayName ?? "",
										pfpUrl: model.result?.data?.pfpURL ?? "",
										allowance: model.result?.data?.tips?.currentCycle?.allowance ?? 0,
										given: model.result?.data?.tips?.currentCycle?.givenAmount ?? 0,
										received: model.result?.data?.tips?.currentCycle?.receivedAmount ?? 0,
										balance: model.result?.data?.tips?.currentCycle?.userBalance ?? "0",
										tipMin: model.result?.data?.tips?.currentCycle?.tipMinimum ?? 0,
										rank: model.result?.data?.tips?.rank ?? 0)
	}
}
