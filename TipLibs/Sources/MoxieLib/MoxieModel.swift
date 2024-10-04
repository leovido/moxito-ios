import Foundation

public enum MoxieTransactionStatus: String, Codable, Hashable {
	case REQUESTED
	case SUCCESS
}

public struct MoxieSplits: Codable {
	public let rewardDistributionPercentage: RewardDistributionPercentage
}

// MARK: - RewardDistributionPercentage
public struct RewardDistributionPercentage: Codable {
	public let channelFans, creator, creatorFans, network: Int
}

extension MoxieSplits {
	public static let placeholder: Self = .init(rewardDistributionPercentage: .init(channelFans: 20, creator: 50, creatorFans: 20, network: 10))
}

// MARK: - MoxieClaimStatus
public struct MoxieClaimStatus: Codable, Hashable {
	public let transactionID: String?
	public let transactionStatus: MoxieTransactionStatus?
	public let transactionHash: String?
	public let transactionAmount: Int?
	public let transactionAmountInWei: String?
	public let rewardsLastEarnedTimestamp: Date?
	
	public enum CodingKeys: String, CodingKey {
		case transactionID = "transactionId"
		case transactionStatus, transactionHash, transactionAmount, transactionAmountInWei, rewardsLastEarnedTimestamp
	}
	
	public init(transactionID: String?, transactionStatus: MoxieTransactionStatus?, transactionHash: String?, transactionAmount: Int?, transactionAmountInWei: String?, rewardsLastEarnedTimestamp: Date?) {
		self.transactionID = transactionID
		self.transactionStatus = transactionStatus
		self.transactionHash = transactionHash
		self.transactionAmount = transactionAmount
		self.transactionAmountInWei = transactionAmountInWei
		self.rewardsLastEarnedTimestamp = rewardsLastEarnedTimestamp
	}
}

extension MoxieClaimStatus {
	public static let placeholderNil: Self = .init(transactionID: "", transactionStatus: nil, transactionHash: nil, transactionAmount: 0, transactionAmountInWei: nil, rewardsLastEarnedTimestamp: .now)
	
	public static let placeholderRequested: Self = .init(transactionID: "", transactionStatus: .REQUESTED, transactionHash: nil, transactionAmount: 0, transactionAmountInWei: nil, rewardsLastEarnedTimestamp: .now)
}

// MARK: - MoxieClaimModel
public struct MoxieClaimModel: Codable, Hashable {
	public let fid: String?
	public let availableClaimAmount: Int?
	public let minimumClaimableAmountInWei, availableClaimAmountInWei: String?
	public let claimedAmount: Int?
	public let claimedAmountInWei: String?
	public let processingAmount: Double?
	public let processingAmountInWei, tokenAddress: String?
	public let chainID: Int?
	public let transactionID, transactionHash: String?
	public let transactionStatus: MoxieTransactionStatus?
	public let transactionAmount: Double?
	public let transactionAmountInWei: String?
	public let rewardsLastEarnedTimestamp: String?
	
	public enum CodingKeys: String, CodingKey {
		case fid, availableClaimAmount, minimumClaimableAmountInWei, availableClaimAmountInWei, claimedAmount, claimedAmountInWei, processingAmount, processingAmountInWei, tokenAddress
		case chainID = "chainId"
		case transactionID = "transactionId"
		case transactionHash, transactionStatus, transactionAmount, transactionAmountInWei, rewardsLastEarnedTimestamp
	}
}

extension MoxieClaimModel {
	public static let placeholder: Self = .init(fid: "0",
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
																							transactionStatus: .REQUESTED,
																							transactionAmount: 0,
																							transactionAmountInWei: "",
																							rewardsLastEarnedTimestamp: "")
}

public struct MoxieFarcasterScore: Codable, Hashable {
	public let farRank: Decimal
	public let farScore: Decimal
	public let liquidityBoost: Decimal
	public let powerBoost: Decimal
	public let tvl: String
	public let tvlBoost: Decimal
	
	public enum CodingKeys: String, CodingKey {
		case farRank, farScore, liquidityBoost, powerBoost, tvlBoost
		case tvl
	}
	
	public init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		farRank = try values.decodeIfPresent(Decimal.self, forKey: .farRank) ?? 0
		farScore = try values.decodeIfPresent(Decimal.self, forKey: .farScore) ?? 0
		liquidityBoost = try values.decodeIfPresent(Decimal.self, forKey: .liquidityBoost) ?? 0
		powerBoost = try values.decodeIfPresent(Decimal.self, forKey: .powerBoost) ?? 0
		tvl = try values.decodeIfPresent(String.self, forKey: .tvl) ?? ""
		tvlBoost = try values.decodeIfPresent(Decimal.self, forKey: .tvlBoost) ?? 0
	}
	
	public init(farRank: Decimal,
							farScore: Decimal,
							liquidityBoost: Decimal,
							powerBoost: Decimal,
							tvl: String,
							tvlBoost: Decimal
	) {
		self.farRank = farRank
		self.farScore = farScore
		self.liquidityBoost = liquidityBoost
		self.powerBoost = powerBoost
		self.tvl = tvl
		self.tvlBoost = tvlBoost
	}
}

public struct MoxieSplitDetail: Codable, Hashable {
	public let castEarningsAmount: Decimal
	public let frameDevEarningsAmount: Decimal
	public let otherEarningsAmount: Decimal
	public let entityType: String
	
	public enum CodingKeys: String, CodingKey {
		case castEarningsAmount, frameDevEarningsAmount, otherEarningsAmount
		case entityType
	}
	
	public init(castEarningsAmount: Decimal, frameDevEarningsAmount: Decimal, otherEarningsAmount: Decimal, entityType: String) {
		self.castEarningsAmount = castEarningsAmount
		self.frameDevEarningsAmount = frameDevEarningsAmount
		self.otherEarningsAmount = otherEarningsAmount
		self.entityType = entityType
	}
	
	public init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		castEarningsAmount = try values.decodeIfPresent(Decimal.self, forKey: .castEarningsAmount) ?? 0
		frameDevEarningsAmount = try values.decodeIfPresent(Decimal.self, forKey: .frameDevEarningsAmount) ?? 0
		otherEarningsAmount = try values.decodeIfPresent(Decimal.self, forKey: .otherEarningsAmount) ?? 0
		entityType = try values.decodeIfPresent(String.self, forKey: .entityType) ?? ""
	}
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
	public let splitDetails: [MoxieSplitDetail]

	public enum CodingKeys: String, CodingKey {
		case allEarningsAmount, castEarningsAmount, frameDevEarningsAmount, otherEarningsAmount, endTimestamp, startTimestamp, timeframe, socials
		case entityID = "entityId"
		case moxieClaimTotals
		case splitDetails
	}
	
	public init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		allEarningsAmount = try values.decodeIfPresent(Decimal.self, forKey: .allEarningsAmount) ?? 0
		castEarningsAmount = try values.decodeIfPresent(Decimal.self, forKey: .castEarningsAmount) ?? 0
		frameDevEarningsAmount = try values.decodeIfPresent(Decimal.self, forKey: .frameDevEarningsAmount) ?? 0
		otherEarningsAmount = try values.decodeIfPresent(Decimal.self, forKey: .otherEarningsAmount) ?? 0
		endTimestamp = try values.decodeIfPresent(Date.self, forKey: .endTimestamp) ?? .now
		startTimestamp = try values.decodeIfPresent(Date.self, forKey: .startTimestamp) ?? .now
		timeframe = try values.decodeIfPresent(String.self, forKey: .timeframe) ?? ""
		socials = try values.decodeIfPresent([Social].self, forKey: .socials) ?? []
		entityID = try values.decodeIfPresent(String.self, forKey: .entityID) ?? ""
		moxieClaimTotals = try values.decodeIfPresent([MoxieClaimTotal].self, forKey: .moxieClaimTotals) ?? []
		splitDetails = try values.decodeIfPresent([MoxieSplitDetail].self, forKey: .splitDetails) ?? []
	}
	
	public init(allEarningsAmount: Decimal, castEarningsAmount: Decimal, frameDevEarningsAmount: Decimal, otherEarningsAmount: Decimal, endTimestamp: Date, startTimestamp: Date, timeframe: String, socials: [Social], entityID: String, moxieClaimTotals: [MoxieClaimTotal], splitDetails: [MoxieSplitDetail]) {
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
		self.splitDetails = splitDetails
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

public struct ConnectedAddress: Codable, Hashable {
	public let address: String
	public let blockchain: String
	
	public init(address: String, blockchain: String) {
		self.address = address
		self.blockchain = blockchain
	}
}

// MARK: - Social
public struct Social: Codable, Hashable {
	public let profileImage: String
	public let profileDisplayName: String
	public let profileHandle: String
	public let connectedAddresses: [ConnectedAddress]
	public let farcasterScore: MoxieFarcasterScore?

	public init(profileImage: String,
							profileDisplayName: String,
							profileHandle: String,
							connectedAddresses: [ConnectedAddress],
							farcasterScore: MoxieFarcasterScore? = nil) {
		self.profileImage = profileImage
		self.profileDisplayName = profileDisplayName
		self.profileHandle = profileHandle
		self.connectedAddresses = connectedAddresses
		self.farcasterScore = farcasterScore
	}
	
	public init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		profileImage = try values.decodeIfPresent(String.self, forKey: .profileImage) ?? ""
		profileDisplayName = try values.decodeIfPresent(String.self, forKey: .profileDisplayName) ?? ""
		profileHandle = try values.decodeIfPresent(String.self, forKey: .profileHandle) ?? ""
		connectedAddresses = try values.decodeIfPresent([ConnectedAddress].self, forKey: .connectedAddresses) ?? []
		farcasterScore = try values.decodeIfPresent(MoxieFarcasterScore.self, forKey: .farcasterScore)
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
		socials: [
			.init(
				profileImage: "https://wrpcd.net/cdn-cgi/image/anim=true,fit=contain,f=auto,w=336/https%3A%2F%2Fi.imgur.com%2FI2rEbPF.png",
				profileDisplayName: "Tester",
				profileHandle: "@test",
				connectedAddresses: [
					.init(address: "0xDEADBEEFDEADBEEFDEADBEEFDEADBEEFDEADBEEF", blockchain: "ethereum"),
					.init(address: "0xDEADBEEF00000000000000000000000000000000", blockchain: "ethereum")
				],
				farcasterScore: .init(
					farRank: .init(.random(in: 0...100)),
					farScore: .init(.random(in: 0...1000)),
					liquidityBoost: .init(.random(in: 0...1000)),
					powerBoost: .init(.random(in: 0...1000)),
					tvl: "209384",
					tvlBoost: .init(.random(in: 0...1000)))
			)],
		entityID: "0",
		moxieClaimTotals: [
			.init(
				availableClaimAmount: .init(.random(in: 0...10000)),
				claimedAmount: .init(.random(in: 0...10000))
			)
		], splitDetails: [
			.init(castEarningsAmount: 0, frameDevEarningsAmount: 0, otherEarningsAmount: 0, entityType: "CREATOR")
		])
	
	public static let noop: MoxieModel = .init(
		allEarningsAmount: 0,
		castEarningsAmount: 0,
		frameDevEarningsAmount: 0,
		otherEarningsAmount: 0,
		endTimestamp: .now,
		startTimestamp: .now,
		timeframe: "TODAY",
		socials: [
			.init(
				profileImage: "https://wrpcd.net/cdn-cgi/image/anim=true,fit=contain,f=auto,w=336/https%3A%2F%2Fi.imgur.com%2FI2rEbPF.png",
				profileDisplayName: "Tester",
				profileHandle: "@test",
				connectedAddresses: [],
				farcasterScore: .init(
					farRank: 0,
					farScore: 0,
					liquidityBoost: 0,
					powerBoost: 0,
					tvl: "0",
					tvlBoost: 0
			)
			)],
		entityID: "",
		moxieClaimTotals: [
			.init(
				availableClaimAmount: 0,
				claimedAmount: 0
			)
		], splitDetails: [])
}
