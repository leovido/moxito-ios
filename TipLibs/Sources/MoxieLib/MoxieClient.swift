import Foundation

public enum CustomDecoderAndEncoder {
	public static var decoder: JSONDecoder {
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601
		
		return decoder
	}
	
	public static var encoder: JSONEncoder {
		let encoder = JSONEncoder()
		encoder.dateEncodingStrategy = .iso8601
		
		return encoder
	}
}

public enum MoxieFilter: Int {
	case today = 0
	case weekly
	case lifetime
}

extension MoxieFilter: CustomStringConvertible {
	public var description: String {
		switch self {
		case .today:
			return "TODAY"
		case .weekly:
			return "WEEKLY"
		case .lifetime:
			return "LIFETIME"
		}
	}
}

public enum MoxieEndpoint {
	static let dailyRewards = "https://gzkks0v6g8.execute-api.us-east-1.amazonaws.com/prod/moxie-daily"
	static let price = "https://api.dexscreener.com/latest/dex/pairs/base/0x493AD7E1c509dE7c89e1963fe9005EaD49FdD19c"
	static let usersEndpoint = "https://api.neynar.com/v2/farcaster/user/search"
}

public enum MoxieError: LocalizedError {
	case message(String)
}

public protocol MoxieProvider {
	func fetchMoxieStats(userFID: Int, filter: MoxieFilter) async throws -> MoxieModel
	func fetchPrice() async throws -> Decimal
}

public final class MockMoxieClient: MoxieProvider {
	public init() {}
	private let session: URLSession = .init(configuration: .default, delegate: nil, delegateQueue: nil)
	
	public func fetchMoxieStats(userFID: Int,  filter: MoxieFilter) async throws -> MoxieModel {
		return .placeholder
	}
	
	public func fetchPrice() async throws -> Decimal {
		return 0.0043
	}
}

public final class MoxieClient: MoxieProvider {	public init() {}
	private let session: URLSession = .init(configuration: .default, delegate: nil, delegateQueue: nil)
	
	public func fetchPrice() async throws -> Decimal {
		do {
			guard let url = URL(string: MoxieEndpoint.price),
						let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
				throw MoxieError.message("Invalid")
			}
			
			var request = URLRequest(url: components.url!)
			request.cachePolicy = .useProtocolCachePolicy
			
			let (data, _) = try await session.data(for: request)
			let decoder = JSONDecoder()
			decoder.dateDecodingStrategy = .iso8601
			let model = try decoder.decode(MoxiePrice.self, from: data)
			
			return try! Decimal(model.pair.priceUsd, format: .number.precision(.fractionLength(2)))
		} catch {
			throw error
		}
	}
	
	public func fetchMoxieStats(userFID: Int,  filter: MoxieFilter = .today) async throws -> MoxieModel {
		do {
			guard let url = URL(string: MoxieEndpoint.dailyRewards),
						var components = URLComponents(url: url, resolvingAgainstBaseURL: false),
						userFID != 0 else {
				throw MoxieError.message("Invalid")
			}
			
			components.queryItems = [
				.init(name: "fid", value: "\(userFID)"),
				.init(name: "filter", value: filter.description)
			]
			
			var request = URLRequest(url: components.url!)
			request.cachePolicy = .useProtocolCachePolicy
			
			let (data, _) = try await session.data(for: request)
						
			let decoder = JSONDecoder()
			decoder.dateDecodingStrategy = .iso8601
			let model = try decoder.decode(MoxieModel.self, from: data)
			
			return model
		} catch {
			throw error
		}
	}
}
