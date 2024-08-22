import Foundation

// MARK: - HamTipModel
struct HamTipModel: Codable {
	let balance: Balance
	let hamScore: Double
	let todaysAllocation, totalTippedToday: String
	let rank, percentTipped: Int
	let hamLikeConfig: HamLikeConfig
}

// MARK: - Balance
struct Balance: Codable {
	let ham: String
}

// MARK: - HamLikeConfig
struct HamLikeConfig: Codable {
	let id: String
	let amount: Int
	
	enum CodingKeys: String, CodingKey {
		case id = "_id"
		case amount
	}
}
