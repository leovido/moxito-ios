import ActivityKit

#if canImport(ActivityKit)

struct MoxieActivityAttributes: ActivityAttributes {
	public struct ContentState: Codable, Hashable {
		var dailyMoxie: String
		var dailyUSD: String
		var claimableMoxie: String
		var claimableUSD: String

		var username: String
		var fid: String
		var imageURL: String
	}
}

#endif
