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
	static let claimRewards = "https://gzkks0v6g8.execute-api.us-east-1.amazonaws.com/prod/moxie-claim"
	static let price = "https://api.dexscreener.com/latest/dex/pairs/base/0x493AD7E1c509dE7c89e1963fe9005EaD49FdD19c"
	static let usersEndpoint = "https://api.neynar.com/v2/farcaster/user/search"
}

public enum MoxieError {
	case message(String)
	case badRequest
	case rateLimited
}

extension MoxieError: LocalizedError {
	public var errorDescription: String? {
		switch self {
		case .message(let mess):
			return mess
		case .badRequest:
			return "Bad request"
		case .rateLimited:
			return "Rate limited. Please try again in a few minutes"
		}
	}
}

public protocol MoxieProvider {
	func fetchMoxieStats(userFID: Int, filter: MoxieFilter) async throws -> MoxieModel
	func fetchPrice() async throws -> Decimal
	func processClaim(userFID: String, wallet: String) async throws -> MoxieClaimModel
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
	
	public func processClaim(userFID: String, wallet: String) async throws -> MoxieClaimModel {
		dump("claimed moxie request")
		return .placeholder
	}
}

public final actor MoxieClient: MoxieProvider {
	private let session: URLSession

	public init(session: URLSession = .init(configuration: .default, delegate: nil, delegateQueue: nil)) {
		self.session = session
		
		session.configuration.urlCache = URLCache(memoryCapacity: 512_000, diskCapacity: 10_240_000, diskPath: nil)
		session.configuration.requestCachePolicy = .returnCacheDataElseLoad
	}
	
	public func processClaim(userFID: String, wallet: String) async throws -> MoxieClaimModel {
		do {
			guard let url = URL(string: MoxieEndpoint.claimRewards),
						var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
				throw MoxieError.message("Invalid")
			}
			
			components.queryItems = [
				.init(name: "fid", value: userFID),
				.init(name: "wallet", value: wallet)
			]
			
			let request = URLRequest(url: components.url!)
			
			let (data, response) = try await session.data(for: request)
			
			guard let response = response as? HTTPURLResponse else {
				throw MoxieError.badRequest
			}
			
			guard response.statusCode != 400 else {
				throw MoxieError.badRequest
			}
			
			guard response.statusCode != 429 else {
				throw MoxieError.rateLimited
			}
			let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
			dump(json)
			let model = try CustomDecoderAndEncoder.decoder.decode(MoxieClaimModel.self, from: data)
						
			return model
		} catch {
			throw error
		}
	}

	public func fetchPrice() async throws -> Decimal {
		do {
			guard let url = URL(string: MoxieEndpoint.price),
						let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
				throw MoxieError.message("Invalid")
			}
			
			let request = URLRequest(url: components.url!)
			
			let (data, response) = try await session.data(for: request)
			
			guard let response = response as? HTTPURLResponse else {
				throw MoxieError.badRequest
			}
			
			guard response.statusCode != 400 else {
				throw MoxieError.badRequest
			}
			
			guard response.statusCode != 429 else {
				throw MoxieError.rateLimited
			}
			
			let decoder = JSONDecoder()
			decoder.dateDecodingStrategy = .iso8601
			let model = try decoder.decode(MoxiePrice.self, from: data)
			let price = Decimal(string: model.pair.priceUsd)
			
			return price ?? 0
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
			
			let request = URLRequest(url: components.url!)
			
			let (data, response) = try await session.data(for: request)
			
			guard let response = response as? HTTPURLResponse else {
				throw MoxieError.badRequest
			}
			
			guard response.statusCode != 400 else {
				throw MoxieError.badRequest
			}
			
			guard response.statusCode != 429 else {
				throw MoxieError.rateLimited
			}
			
			let decoder = JSONDecoder()
			decoder.dateDecodingStrategy = .iso8601
			let model = try decoder.decode(MoxieModel.self, from: data)
			
			return model
		} catch {
			throw MoxieError.message(error.localizedDescription)
		}
	}
}
