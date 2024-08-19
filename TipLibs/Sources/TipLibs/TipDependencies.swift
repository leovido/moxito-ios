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
	func fetchFartherTips() async throws -> TipModel
}

public struct TipModel: Decodable {
	public var id: UUID
	public var allowance: Int
	public var given: Int
	public var received: Int
	public var balance: String
	public var tipMin: Int
	public var rank: Int
	
	public init(id: UUID, allowance: Int, given: Int, received: Int, balance: String, tipMin: Int, rank: Int) {
		self.id = id
		self.allowance = allowance
		self.given = given
		self.received = received
		self.balance = balance
		self.tipMin = tipMin
		self.rank = rank
	}
}

extension TipModel {
	public static let placeholder = TipModel.init(id: UUID(), allowance: 0, given: 0, received: 0, balance: "0", tipMin: 0, rank: 0)
}

public final class TipClient: TipProvider {
	private let session: URLSession = .init(configuration: .default, delegate: nil, delegateQueue: nil)
	
	public init() {}
	
	public func fetchFartherTips() async throws -> TipModel {
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
		
		let request = URLRequest(url: components.url!)
		
		let (data, _) = try await session.data(for: request)
		
		let model = try JSONDecoder().decode(FartherTipModel.self, from: data)
		
		return TipModel(id: UUID(),
										allowance: model.result?.data?.tips?.currentCycle?.allowance ?? 0,
										given: model.result?.data?.tips?.currentCycle?.givenAmount ?? 0,
										received: model.result?.data?.tips?.currentCycle?.receivedAmount ?? 0,
										balance: model.result?.data?.tips?.currentCycle?.userBalance ?? "0",
										tipMin: model.result?.data?.tips?.currentCycle?.tipMinimum ?? 0,
										rank: model.result?.data?.tips?.rank ?? 0)
	}
}
