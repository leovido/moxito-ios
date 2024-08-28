import Foundation

public enum MoxieEndpoint {
	static let dailyRewards = "http://localhost:3000/moxie-daily"
}

public enum MoxieError: LocalizedError {
	case message(String)
}

public protocol MoxieProvider {
	func fetchMoxieStats(userFID: Int) async throws -> MoxieModel
}

extension MoxieModel {
	public static let placeholder: MoxieModel = .init(
		allEarningsAmount: Decimal.init(123),
		castEarningsAmount: Decimal.init(123),
		frameDevEarningsAmount: Int.random(in: 1...1000),
		otherEarningsAmount: Int.random(in: 1...1000),
		endTimestamp: .now,
		startTimestamp: .now, 
		timeframe: "TODAY",
		socials: [.init(isFarcasterPowerUser: true, profileImage: "", profileDisplayName: "Name", profileHandle: "@test")],
		entityID: "203666",
		moxieClaimTotals: [
			.init(availableClaimAmount: Decimal.init(123),
						claimedAmount: Decimal.init(123))])
}

public final class MoxieClient: MoxieProvider {
	public init() {}
	private let session: URLSession = .init(configuration: .default, delegate: nil, delegateQueue: nil)
	
	public func fetchMoxieStats(userFID: Int) async throws -> MoxieModel {
		let url = URL(string: MoxieEndpoint.dailyRewards)!
		
		guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
			throw MoxieError.message("Invalid")
		}
		
		components.queryItems = [
			.init(name: "fid", value: "\(userFID)")
		]
		
		var request = URLRequest(url: components.url!)
		request.cachePolicy = .useProtocolCachePolicy
		
		let (data, _) = try await session.data(for: request)
		dump(data)
		dump("here")
		let json = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as! [String: Any]
		dump(json)
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601
		let model = try! decoder.decode(MoxieModel.self, from: data)
		
		return model
	}
}
