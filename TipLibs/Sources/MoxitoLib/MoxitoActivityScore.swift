import Foundation

// MARK: - MoxitoActivity
public struct MoxitoActivity: Codable, Hashable {
	public let rounds: [Round]
	public let totalPoints: Double
	public let fid: String
	
	enum CodingKeys: String, CodingKey {
		case rounds, totalPoints, fid
	}
}

// MARK: - Round
public struct Round: Codable, Hashable {
	public let id: String
	public let title, roundNumber: Int
	public let startDate, endDate: Date
	public let results: [Result]
}

// MARK: - Result
public struct Result: Codable, Hashable {
	public let timestamp: Date
	public let points: Double
	public let id: String
}
