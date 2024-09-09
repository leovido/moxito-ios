import Foundation

public struct MoxieClaimModel: Codable {
		public let fid: String?
		public let availableClaimAmount: Int?
		public let minimumClaimableAmountInWei, availableClaimAmountInWei: String?
		public let claimedAmount: Int?
		public let claimedAmountInWei: String?
		public let processingAmount: Double?
		public let processingAmountInWei, tokenAddress: String?
		public let chainID: Int?
		public let transactionID, transactionHash, transactionStatus: String?
		public let transactionAmount: Double?
		public let transactionAmountInWei, rewardsLastEarnedTimestamp: String?

		public enum CodingKeys: String, CodingKey {
				case fid, availableClaimAmount, minimumClaimableAmountInWei, availableClaimAmountInWei, claimedAmount, claimedAmountInWei, processingAmount, processingAmountInWei, tokenAddress
				case chainID = "chainId"
				case transactionID = "transactionId"
				case transactionHash, transactionStatus, transactionAmount, transactionAmountInWei, rewardsLastEarnedTimestamp
		}
}

extension MoxieClaimModel {
	static let placeholder: Self = .init(fid: "0",
																			 availableClaimAmount: 1,
																			 minimumClaimableAmountInWei: "1",
																			 availableClaimAmountInWei: "",
																			 claimedAmount: 123, 
																			 claimedAmountInWei: "",
																			 processingAmount: 1,
																			 processingAmountInWei: "",
																			 tokenAddress: "",
																			 chainID: 5453,
																			 transactionID: "",
																			 transactionHash: "",
																			 transactionStatus: "",
																			 transactionAmount: 0,
																			 transactionAmountInWei: "",
																			 rewardsLastEarnedTimestamp: "")
}


// MARK: - MoxieModel
public struct MoxieModel: Codable, Hashable {
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
public struct MoxieClaimTotal: Codable, Hashable {
	public let availableClaimAmount: Decimal
	public let claimedAmount: Decimal
	
	public init(availableClaimAmount: Decimal, claimedAmount: Decimal) {
		self.availableClaimAmount = availableClaimAmount
		self.claimedAmount = claimedAmount
	}
}

// MARK: - Social
public struct Social: Codable, Hashable {
	public let profileImage: String
	public let profileDisplayName, profileHandle: String
	
	public init(profileImage: String, profileDisplayName: String, profileHandle: String) {
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
		socials: [.init(profileImage: "https://imagedelivery.net/BXluQx4ige9GuW0Ia56BHw/883cecce-71a6-4f84-68da-426bedf00e00/rectcrop3", profileDisplayName: "Leovido🎩", profileHandle: "@test")],
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
		socials: [.init(profileImage: "", profileDisplayName: "Anon", profileHandle: "")],
		entityID: "",
		moxieClaimTotals: [
			.init(
				availableClaimAmount: 0,
				claimedAmount: 0
			)
		])
}
