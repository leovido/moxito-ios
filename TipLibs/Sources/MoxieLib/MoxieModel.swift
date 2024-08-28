import Foundation

// MARK: - MoxieModel
public struct MoxieModel: Codable {
	public let allEarningsAmount, castEarningsAmount: Decimal
	public let frameDevEarningsAmount, otherEarningsAmount: Int
	public let endTimestamp, startTimestamp: Date
	public let timeframe: String
	public let socials: [Social]
	public let entityID: String
	public let moxieClaimTotals: [MoxieClaimTotal]
	
	public enum CodingKeys: String, CodingKey {
		case allEarningsAmount, castEarningsAmount, frameDevEarningsAmount, otherEarningsAmount, endTimestamp, startTimestamp, timeframe, socials
		case entityID = "entityId"
		case moxieClaimTotals
	}
	public init(allEarningsAmount: Decimal, castEarningsAmount: Decimal, frameDevEarningsAmount: Int, otherEarningsAmount: Int, endTimestamp: Date, startTimestamp: Date, timeframe: String, socials: [Social], entityID: String, moxieClaimTotals: [MoxieClaimTotal]) {
		self.allEarningsAmount = allEarningsAmount
		self.castEarningsAmount = castEarningsAmount
		self.frameDevEarningsAmount = frameDevEarningsAmount
		self.otherEarningsAmount = otherEarningsAmount
		self.endTimestamp = endTimestamp
		self.startTimestamp = startTimestamp
		self.timeframe = timeframe
		self.socials = socials
		self.entityID = entityID
		self.moxieClaimTotals = moxieClaimTotals
	}
}

// MARK: - MoxieClaimTotal
public struct MoxieClaimTotal: Codable {
	public let availableClaimAmount: Decimal
	public let claimedAmount: Decimal
	
	public init(availableClaimAmount: Decimal, claimedAmount: Decimal) {
		self.availableClaimAmount = availableClaimAmount
		self.claimedAmount = claimedAmount
	}
}

// MARK: - Social
public struct Social: Codable {
	public let isFarcasterPowerUser: Bool
	public let profileImage: String
	public let profileDisplayName, profileHandle: String
	
	public init(isFarcasterPowerUser: Bool, profileImage: String, profileDisplayName: String, profileHandle: String) {
		self.isFarcasterPowerUser = isFarcasterPowerUser
		self.profileImage = profileImage
		self.profileDisplayName = profileDisplayName
		self.profileHandle = profileHandle
	}
}
