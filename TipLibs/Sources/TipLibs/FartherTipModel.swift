import Foundation

// MARK: - FartherTipModel
public struct FartherTipModel: Codable {
	public var result: Result?
}

// MARK: - Result
public struct Result: Codable {
	public var data: DataClass?
}

// MARK: - DataClass
public struct DataClass: Codable {
	public var fid: Int?
	public var username, displayName: String?
	public var pfpURL: String?
	public var followerCount: Int?
	public var powerBadge: Bool?
	public var tipperScore: Double?
	public var tips: Tips?
	public var allocations: [Allocation]?
	
	enum CodingKeys: String, CodingKey {
		case fid, username, displayName
		case pfpURL = "pfpUrl"
		case followerCount, powerBadge, tipperScore, tips, allocations
	}
}

// MARK: - Allocation
public struct Allocation: Codable {
	public var id, createdAt, amount: String?
	public var isClaimed: Bool?
	public var index: Int?
	public var type, address: String?
	public var airdrop: Airdrop?
}

// MARK: - Airdrop
public struct Airdrop: Codable {
	public var id, address, startTime, endTime: String?
}

// MARK: - Tips
public struct Tips: Codable {
	public var rank: Int?
	public var totals: Totals?
	public var currentCycle: CurrentCycle?
}

// MARK: - CurrentCycle
public struct CurrentCycle: Codable {
	public var startTime: String?
	public var allowance: Int?
	public var userBalance: String?
	public var givenCount: Int?
	public var tippedFids: [Int]?
	public var givenAmount, remainingAllowance: Int?
	public var invalidatedAmount: Int?
	public var receivedCount, receivedAmount, tipMinimum, eligibleTippers: Int?
}

// MARK: - Totals
public struct Totals: Codable {
	public var givenCount, givenAmount, receivedCount, receivedAmount: Int?
}
