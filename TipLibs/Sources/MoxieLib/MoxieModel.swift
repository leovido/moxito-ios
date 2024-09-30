import Foundation

public enum MoxieTransactionStatus: String, Codable, Hashable {
	case REQUESTED
	case SUCCESS
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
	
	public init(profileImage: String,
							profileDisplayName: String,
							profileHandle: String,
							connectedAddresses: [ConnectedAddress]) {
		self.profileImage = profileImage
		self.profileDisplayName = profileDisplayName
		self.profileHandle = profileHandle
		self.connectedAddresses = connectedAddresses
	}
	
	public init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		profileImage = try values.decodeIfPresent(String.self, forKey: .profileImage) ?? ""
		profileDisplayName = try values.decodeIfPresent(String.self, forKey: .profileDisplayName) ?? ""
		profileHandle = try values.decodeIfPresent(String.self, forKey: .profileHandle) ?? ""
		connectedAddresses = try values.decodeIfPresent([ConnectedAddress].self, forKey: .connectedAddresses) ?? []
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
		socials: [.init(profileImage: "https://wrpcd.net/cdn-cgi/image/anim=true,fit=contain,f=auto,w=336/https%3A%2F%2Fi.imgur.com%2FI2rEbPF.png", profileDisplayName: "Tester", profileHandle: "@test", connectedAddresses: [
			.init(address: "0xDEADBEEFDEADBEEFDEADBEEFDEADBEEFDEADBEEF", blockchain: "ethereum"),
			.init(address: "0xDEADBEEF00000000000000000000000000000000", blockchain: "ethereum")
		])],
		entityID: "0",
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
		socials: [.init(profileImage: "", profileDisplayName: "No user", profileHandle: "", connectedAddresses: [])],
		entityID: "",
		moxieClaimTotals: [
			.init(
				availableClaimAmount: 0,
				claimedAmount: 0
			)
		])
}
