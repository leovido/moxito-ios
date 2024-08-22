import Foundation

public enum HamEndpoint {
	static let hamTips = "https://farcaster.dep.dev/ham/user"
}

public enum HamClientError: LocalizedError {
	case message(String)
}

public protocol HamProvider {
	func fetchHamTips(userFID: Int) async throws -> TipModel
}

extension TipModel {
	public static let hamPlaceholder: TipModel = .init(
		id: UUID(),
		fid: 203666,
		username: "Leovido🎩✨",
		displayName: "@leovido.eth",
		pfpUrl: "https://imagedelivery.net/BXluQx4ige9GuW0Ia56BHw/883cecce-71a6-4f84-68da-426bedf00e00/rectcrop3",
		allowance: 5000,
		given: 2000,
		received: 69000,
		balance: "335469188489011551627074",
		tipMin: 0,
		rank: 21
	)
}

public final class HamClient: HamProvider {
	private let session: URLSession = .init(configuration: .default, delegate: nil, delegateQueue: nil)
	private let cacheManager: CacheManager
	
	public init(cacheManager: CacheManager = .init()) {
		self.cacheManager = cacheManager
	}
	
	public func fetchHamTips(userFID: Int) async throws -> TipModel {
		var url = URL(string: HamEndpoint.hamTips)!
		url.append(path: "\(userFID)")
		
		guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
			throw TipError.message("Invalid")
		}
		
		var request = URLRequest(url: components.url!)
		request.cachePolicy = .useProtocolCachePolicy
		
		let data = try await cacheManager.fetchData(for: request, forceRemote: true)
		let model = try JSONDecoder().decode(HamTipModel.self, from: data)
		
		let allowance = Double(model.todaysAllocation) ?? 0 * pow(10, -18)
		let given = Double(model.totalTippedToday) ?? 0 * pow(10, -18)

		return TipModel(id: UUID(),
										fid: userFID,
										username: "Leovido",
										displayName: "Leovido",
										pfpUrl: "https://imagedelivery.net/BXluQx4ige9GuW0Ia56BHw/883cecce-71a6-4f84-68da-426bedf00e00/rectcrop3",
										allowance: Int(String(allowance)) ?? 0,
										given: Int(String(given)) ?? 0,
										received: 0,
										balance: model.balance.ham,
										tipMin: 0,
										rank: model.rank)
	}
}
