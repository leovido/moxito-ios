import Foundation

public enum CustomDecoderAndEncoder {
	public static var decoder: JSONDecoder {
		let formatter = DateFormatter()
		formatter.calendar = Calendar(identifier: .iso8601)
		formatter.locale = Locale(identifier: "en_US_POSIX")
		formatter.timeZone = TimeZone(secondsFromGMT: 0)
		
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .custom({ (decoder) -> Date in
			let container = try decoder.singleValueContainer()
			let dateStr = try container.decode(String.self)
			
			formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
			if let date = formatter.date(from: dateStr) {
				return date
			}
			formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
			if let date = formatter.date(from: dateStr) {
				return date
			}
			fatalError()
		})
		
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
	static let dailyRewards = "https://w8wn0nevnc.execute-api.eu-west-1.amazonaws.com/prod/moxie-daily"
	static let claimRewards = "https://gzkks0v6g8.execute-api.us-east-1.amazonaws.com/prod/moxie-claim"
	static let splits = "https://gzkks0v6g8.execute-api.us-east-1.amazonaws.com/prod/moxie-splits"
	static let fansCount = "https://gzkks0v6g8.execute-api.us-east-1.amazonaws.com/prod/moxie-fans-count"
	static let claimRewardsStatus = "https://gzkks0v6g8.execute-api.us-east-1.amazonaws.com/prod/moxie-claim-status"
	static let cherylWidgetEligible = "https://gzkks0v6g8.execute-api.us-east-1.amazonaws.com/prod/check-cheryl-ft"
	static let fitnessRewards = "https://gzkks0v6g8.execute-api.us-east-1.amazonaws.com/prod/fitness-rewards"
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
	func fetchClaimStatus(fid: String, transactionId: String) async throws -> MoxieClaimStatus
	func fetchRewardSplits(fid: String) async throws -> MoxieSplits
	func fetchFansCount(fid: String) async throws -> Int
	func fetchTotalPoolRewards() async throws -> Decimal
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
		return .placeholder
	}
	
	public func fetchClaimStatus(fid: String, transactionId: String) async throws -> MoxieClaimStatus {
		return .placeholderRequested
	}
	
	public func fetchRewardSplits(fid: String) async throws -> MoxieSplits {
		return .placeholder
	}
	
	public func fetchFansCount(fid: String) async throws -> Int {
		return 1000
	}
	
	public func fetchTotalPoolRewards() async throws -> Decimal {
		return 0
	}
}

public final class MockFailMoxieClient: MoxieProvider {
	public init() {}
	private let session: URLSession = .init(configuration: .default, delegate: nil, delegateQueue: nil)
	
	public func fetchMoxieStats(userFID: Int,  filter: MoxieFilter) async throws -> MoxieModel {
		throw MoxieError.message("Invalid")
	}
	
	public func fetchPrice() async throws -> Decimal {
		return 0.0043
	}
	
	public func processClaim(userFID: String, wallet: String) async throws -> MoxieClaimModel {
		throw MoxieError.message("Invalid")
	}
	
	public func fetchClaimStatus(fid: String, transactionId: String) async throws -> MoxieClaimStatus {
		throw MoxieError.message("Invalid")
	}
	
	public func fetchRewardSplits(fid: String) async throws -> MoxieSplits {
		throw MoxieError.message("Invalid")
	}
	
	public func fetchFansCount(fid: String) async throws -> Int {
		throw MoxieError.message("Invalid")
	}
	
	public func fetchTotalPoolRewards() async throws -> Decimal {
		throw MoxieError.message("Invalid")
	}
}

public final actor MoxieClient: MoxieProvider {
	private let session: URLSession

	public init(session: URLSession = .init(configuration: .default, delegate: nil, delegateQueue: nil)) {
		self.session = session
		
		session.configuration.urlCache = URLCache(memoryCapacity: 512_000, diskCapacity: 10_240_000, diskPath: nil)
		session.configuration.requestCachePolicy = .returnCacheDataElseLoad
	}
	
	public func fetchClaimStatus(fid: String, transactionId: String) async throws -> MoxieClaimStatus {
		do {
			guard let url = URL(string: MoxieEndpoint.claimRewardsStatus),
						var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
				throw MoxieError.message("Invalid")
			}
			
			components.queryItems = [
				.init(name: "fid", value: fid),
				.init(name: "transactionId", value: transactionId),
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
			let model = try CustomDecoderAndEncoder.decoder.decode(MoxieClaimStatus.self, from: data)
						
			return model
		} catch {
			throw error
		}
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
	
	public func fetchRewardSplits(fid: String) async throws -> MoxieSplits {
		do {
			guard let url = URL(string: MoxieEndpoint.splits),
						var components = URLComponents(url: url, resolvingAgainstBaseURL: false),
						!fid.isEmpty else {
				throw MoxieError.message("Invalid")
			}
			
			components.queryItems = [
				.init(name: "fid", value: "\(fid)"),
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
			let model = try decoder.decode(MoxieSplits.self, from: data)
			
			return model
		} catch {
			throw MoxieError.message(error.localizedDescription)
		}
	}
	
	public func fetchFansCount(fid: String) async throws -> Int {
		do {
			guard let url = URL(string: MoxieEndpoint.fansCount),
						var components = URLComponents(url: url, resolvingAgainstBaseURL: false),
						!fid.isEmpty else {
				throw MoxieError.message("Invalid fans count endpoint")
			}
			
			components.queryItems = [
				.init(name: "fid", value: "\(fid)"),
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
			
			guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
						let fansCount = json["fans"] as? Int else {
				return 0
			}
			return fansCount
			
		} catch {
			throw MoxieError.message(error.localizedDescription)
		}
	}
	
	public func fetchTotalPoolRewards() async throws -> Decimal {
		do {
			guard let url = URL(string: MoxieEndpoint.fitnessRewards) else {
				throw MoxieError.message("Invalid fans count endpoint")
			}
			
			let request = URLRequest(url: url)
			
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
			
			guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
				return 0
			}
			
			let value = json["totalRewards"] as! Double
			let rewards = Decimal(value)
			return rewards
			
		} catch {
			throw MoxieError.message(error.localizedDescription)
		}
	}
}
