import Foundation

// MARK: - FarcasterUser
public struct FarcasterUser: Codable {
	public let result: Result
}

// MARK: - Result
public struct Result: Codable {
	public let users: [User]
	public let next: Next
}

// MARK: - Next
public struct Next: Codable {
	public let cursor: String?
}

// MARK: - User
public struct User: Codable, Identifiable, Hashable {
	public var id: String {
		return UUID().uuidString
	}
	public let object: String
	public let fid: Int
	public let custodyAddress, username, displayName: String?
	public let pfpURL: String
	public let profile: Profile
	public let followerCount, followingCount: Int
	public let verifications: [String]
	public let verifiedAddresses: VerifiedAddresses
	public let activeStatus: String
	public let powerBadge: Bool
	public let viewerContext: ViewerContext
	
	public enum CodingKeys: String, CodingKey {
		case object, fid
		case custodyAddress = "custody_address"
		case username
		case displayName = "display_name"
		case pfpURL = "pfp_url"
		case profile
		case followerCount = "follower_count"
		case followingCount = "following_count"
		case verifications
		case verifiedAddresses = "verified_addresses"
		case activeStatus = "active_status"
		case powerBadge = "power_badge"
		case viewerContext = "viewer_context"
	}
}

// MARK: - Profile
public struct Profile: Codable, Hashable {
	public let bio: Bio
}

// MARK: - Bio
public struct Bio: Codable, Hashable {
	public let text: String
}

// MARK: - VerifiedAddresses
public struct VerifiedAddresses: Codable, Hashable {
	public let ethAddresses, solAddresses: [String]
	
	public enum CodingKeys: String, CodingKey {
		case ethAddresses = "eth_addresses"
		case solAddresses = "sol_addresses"
	}
}

// MARK: - ViewerContext
public struct ViewerContext: Codable, Hashable {
	public let following, followedBy: Bool
	
	public enum CodingKeys: String, CodingKey {
		case following
		case followedBy = "followed_by"
	}
}
