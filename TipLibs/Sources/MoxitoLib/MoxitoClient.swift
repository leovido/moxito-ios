import Foundation

public enum MoxitoError: Error {
	case message(String)
	case badRequest
	case rateLimited
}

public struct MoxitoScoreModel: Identifiable, Codable, Hashable {
	public var id: UUID = UUID()
	public let score: Decimal
	public let fid: Int
	public let checkInDate: Date
	public let createdAt: Date
	public var weightFactorId: String = "0dd3ab92-d855-4975-a2c4-acb74462305b"
	
	public init(score: Decimal, fid: Int, checkInDate: Date, createdAt: Date = Date(), weightFactorId: String) {
		self.score = score
		self.fid = fid
		self.checkInDate = checkInDate
		self.createdAt = createdAt
		self.weightFactorId = weightFactorId
	}
	
	public init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		id = UUID()
		fid = try values.decodeIfPresent(Int.self, forKey: .fid) ?? 0
		checkInDate = try values.decodeIfPresent(Date.self, forKey: .checkInDate) ?? Date()
		createdAt = try values.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
		weightFactorId = try values.decodeIfPresent(String.self, forKey: .weightFactorId) ?? ""
		score = try values.decodeIfPresent(Decimal.self, forKey: .score) ?? 0
	}
}

extension MoxitoError: LocalizedError {
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

public struct MoxitoCheckinModel: Codable, Hashable {
	public let fid: Int
	public let username: String
	public let roundId: String
	public let createdAt: Date
	
	public init (fid: Int, username: String, roundId: String, createdAt: Date) {
		self.fid = fid
		self.username = username
		self.roundId = roundId
		self.createdAt = createdAt
	}
	
	public init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		fid = try values.decodeIfPresent(Int.self, forKey: .fid) ?? 0
		username = try values.decodeIfPresent(String.self, forKey: .username) ?? ""
		roundId = try values.decodeIfPresent(String.self, forKey: .roundId) ?? ""
		createdAt = try values.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
	}
}

public enum MoxitoEndpoint {
	static let checkins = "https://moxito.xyz/api/checkins"
	static let scores = "https://moxito.xyz/api/scores"
}

public final class MoxitoClient {
	public init() {}
	private let session: URLSession = .init(configuration: .default, delegate: nil, delegateQueue: nil)
	
	public func postScore(model: MoxitoScoreModel) async throws -> Bool {
		do {
			guard let url = URL(string: MoxitoEndpoint.scores),
						model.fid > 0 else {
				throw MoxitoError.message("Invalid")
			}
			
			let d = try CustomDecoderAndEncoder.encoder.encode(model)
			
			var request = URLRequest(url: url)
			
			request.httpMethod = "POST"
			request.httpBody = d
			
			let (data, response) = try await session.data(for: request)
			
			guard let response = response as? HTTPURLResponse else {
				throw MoxitoError.badRequest
			}
			
			guard response.statusCode != 400 else {
				throw MoxitoError.badRequest
			}
			
			guard response.statusCode != 429 else {
				throw MoxitoError.rateLimited
			}
			return true
		} catch {
			throw error
		}
	}
	
	public func fetchAllScores(fid: Int) async throws -> [MoxitoScoreModel] {
		do {
			guard let url = URL(string: MoxitoEndpoint.scores),
						var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
				throw MoxitoError.message("Invalid")
			}
			
			components.queryItems = [
				.init(name: "fid", value: fid.description)
			]
			
			let request = URLRequest(url: components.url!)
			
			let (data, response) = try await session.data(for: request)
			
			guard let response = response as? HTTPURLResponse else {
				throw MoxitoError.badRequest
			}
			
			guard response.statusCode != 400 else {
				throw MoxitoError.badRequest
			}
			
			guard response.statusCode != 429 else {
				throw MoxitoError.rateLimited
			}
			
			let decoder = CustomDecoderAndEncoder.decoder
			let models = try decoder.decode([MoxitoScoreModel].self, from: data)
			
			return models
		} catch {
			throw error
		}
	}
	
	public func fetchAllCheckinsByUse(fid: Int, startDate: Date, endDate: Date) async throws -> [MoxitoCheckinModel] {
		do {
			guard let url = URL(string: MoxitoEndpoint.checkins),
						var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
				throw MoxitoError.message("Invalid")
			}
			
			let startDateString = startDate.formatted(.iso8601)
			let endDateString = endDate.formatted(.iso8601)
			
			components.queryItems = [
				.init(name: "fid", value: fid.description),
				.init(name: "startDate", value: startDateString),
				.init(name: "endDate", value: endDateString),
			]
			
			let request = URLRequest(url: components.url!)
			
			let (data, response) = try await session.data(for: request)
			
			guard let response = response as? HTTPURLResponse else {
				throw MoxitoError.badRequest
			}
			
			guard response.statusCode != 400 else {
				throw MoxitoError.badRequest
			}
			
			guard response.statusCode != 429 else {
				throw MoxitoError.rateLimited
			}
			
			let decoder = CustomDecoderAndEncoder.decoder
			let models = try decoder.decode([MoxitoCheckinModel].self, from: data)
			
			return models
		} catch {
			throw error
		}
	}
}
