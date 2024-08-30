import Foundation

// MARK: - MoxieModel
public struct MoxieModel: Codable {
	public let allEarningsAmount, castEarningsAmount: Decimal
	public let frameDevEarningsAmount, otherEarningsAmount: Decimal
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
	public init(allEarningsAmount: Decimal, castEarningsAmount: Decimal, frameDevEarningsAmount: Decimal, otherEarningsAmount: Decimal, endTimestamp: Date, startTimestamp: Date, timeframe: String, socials: [Social], entityID: String, moxieClaimTotals: [MoxieClaimTotal]) {
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

extension MoxieModel {
	public static let placeholder: MoxieModel = .init(
		allEarningsAmount: .init(.random(in: 0...10000)),
		castEarningsAmount: .init(.random(in: 0...10000)),
		frameDevEarningsAmount: .init(.random(in: 0...10000)),
		otherEarningsAmount: .init(.random(in: 0...10000)),
		endTimestamp: .now,
		startTimestamp: .now,
		timeframe: "TODAY",
		socials: [.init(isFarcasterPowerUser: true, profileImage: "https://imagedelivery.net/BXluQx4ige9GuW0Ia56BHw/883cecce-71a6-4f84-68da-426bedf00e00/rectcrop3", profileDisplayName: "Leovido🎩", profileHandle: "@test")],
		entityID: "203666",
		moxieClaimTotals: [
			.init(
				availableClaimAmount: .init(.random(in: 0...10000)),
				claimedAmount: .init(.random(in: 0...10000))
			)
		])
	
	public static let noop: MoxieModel = .init(
		allEarningsAmount: 0,
		castEarningsAmount: 0,
		frameDevEarningsAmount: 0,
		otherEarningsAmount: 0,
		endTimestamp: .now,
		startTimestamp: .now,
		timeframe: "TODAY",
		socials: [.init(isFarcasterPowerUser: false, profileImage: "", profileDisplayName: "Anon", profileHandle: "")],
		entityID: "-1",
		moxieClaimTotals: [
			.init(
				availableClaimAmount: 0,
				claimedAmount: 0
			)
		])
}
