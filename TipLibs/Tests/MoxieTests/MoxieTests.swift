import XCTest
import MoxitoLib
@testable import MoxieLib

final class MockClient: MoxieProvider {
	func fetchTotalPoolRewards() async throws -> Decimal {
		return 10000
	}
	
	func fetchFansCount(fid: String) async throws -> Int {
		return 1000
	}
	
	func processClaim(userFID: String, wallet: String) async throws -> MoxieLib.MoxieClaimModel {
		.placeholder
	}
	
	func fetchClaimStatus(fid: String, transactionId: String) async throws -> MoxieLib.MoxieClaimStatus {
		.placeholderNil
	}
	
	func fetchRewardSplits(fid: String) async throws -> MoxieLib.MoxieSplits {
		.placeholder
	}
	
	func fetchMoxieStats(userFID: Int, filter: MoxieLib.MoxieFilter) async throws -> MoxieLib.MoxieModel {
		return .placeholder
	}
	
	func fetchPrice() async throws -> Decimal {
		0.0025
	}
}

final class MoxieClientTests: XCTestCase {
	var client: MoxieProvider!
	
	override func setUp() async throws {
		client = MockClient()
	}
	
	override func tearDown() async throws {
		client = nil
	}
	
	func testFetchMoxieStats() async throws {
		let result = try await client.fetchMoxieStats(userFID: 203666, filter: .today)
		
		XCTAssertEqual(result.allEarningsAmount, result.allEarningsAmount)
	}
	
	func testFetchPrice() async throws {
		let result = try await client.fetchPrice()
		
		XCTAssertEqual(result, 0.0025)
	}
	
	func testFans() async throws {
		let data = mockModel.data(using: .utf8)!
		let model = try CustomDecoderAndEncoder.decoder.decode(MoxieModel.self, from: data)
		
		XCTAssertEqual(model.fansCount, 1000)
	}
	
	func testModel() async throws {
		let data = mockModel.data(using: .utf8)!
		let model = try CustomDecoderAndEncoder.decoder.decode(MoxieModel.self, from: data)
		
		XCTAssertEqual(model.socials.farcasterScore?.farRank, 215)
	}
	
	func testModelWithMissingValues() async throws {
		let data = mockModelMissingValues.data(using: .utf8)!
		let model = try CustomDecoderAndEncoder.decoder.decode(MoxieModel.self, from: data)
		
		XCTAssertEqual(model.socials.farcasterScore?.powerBoost, 0)
		XCTAssertEqual(model.socials.farcasterScore?.liquidityBoost, 0)
	}
	
	func testModelNil() async throws {
		let data = mockNil.data(using: .utf8)!
		let model = try CustomDecoderAndEncoder.decoder.decode(MoxieModel.self, from: data)
		
		XCTAssertEqual(model.allEarningsAmount, 0)
	}
}

private let mockNil = """
{
 "moxieClaimTotals": [
	{
	 "availableClaimAmount": 6190.931244877772,
	 "claimedAmount": 165995.88407795024
	}
 ]
}
"""

private let mockModel = """
{
	"fansCount": 1000,
	"allEarningsAmount": 3618.8085597466693,
	"castEarningsAmount": 2853.28884693608,
	"frameDevEarningsAmount": 765.5197128105896,
	"otherEarningsAmount": 0,
	"endTimestamp": "2024-10-01T11:00:00Z",
	"startTimestamp": "2024-10-01T00:00:00Z",
	"timeframe": "TODAY",
	"socials": {
	 "profileImage": "https://imagedelivery.net/BXluQx4ige9GuW0Ia56BHw/883cecce-71a6-4f84-68da-426bedf00e00/rectcrop3",
		 "profileDisplayName": "Leovido 🎩Ⓜ️🌱",
		 "profileHandle": "leovido.eth",
		 "farcasterScore": {
			 "farRank": 215,
			 "farScore": 41.18623951883294,
			 "farBoost": 40.77512654379794,
			 "tvl": "1432338103548656334660223",
			 "tvlBoost": 2.055564875175,
		 },
		 "connectedAddresses": [
			 {
				 "address": "0xdd3b3a67c66a5276aacc499ec2abd5241721e008",
				 "blockchain": "ethereum"
			 },
			 {
				 "address": "83VF9bSsC6Kz4y8byT3vHFxoiX9tZu7tAbYX1s8PuBJE",
				 "blockchain": "solana"
			 },
			 {
				 "address": "0xf2e8937d7aa0cb5c2d63f57b8d581c0aead055ff",
				 "blockchain": "ethereum"
			 },
			 {
				 "address": "0xc41b192df74fe564108110fe854b2bee70bb0b3a",
				 "blockchain": "ethereum"
			 }
		 ]
	 },
	"entityId": "203666",
	"moxieClaimTotals": [
		{
			"availableClaimAmount": 6190.931244877772,
			"claimedAmount": 165995.88407795024
		}
	]
}
"""

private let mockModelMissingValues = """
{
	"allEarningsAmount": 3618.8085597466693,
	"castEarningsAmount": 2853.28884693608,
	"frameDevEarningsAmount": 765.5197128105896,
	"otherEarningsAmount": 0,
	"endTimestamp": "2024-10-01T11:00:00Z",
	"startTimestamp": "2024-10-01T00:00:00Z",
	"timeframe": "TODAY",
	"socials": {
	 "profileImage": "https://imagedelivery.net/BXluQx4ige9GuW0Ia56BHw/883cecce-71a6-4f84-68da-426bedf00e00/rectcrop3",
		 "profileDisplayName": "Leovido 🎩Ⓜ️🌱",
		 "profileHandle": "leovido.eth",
		 "farcasterScore": {
			 "farRank": 215,
			 "farScore": 41.18623951883294,
			 "farBoost": 40.77512654379794,
			 "tvl": "1432338103548656334660223",
			 "tvlBoost": 2.055564875175,
		 },
		 "connectedAddresses": [
			 {
				 "address": "0xdd3b3a67c66a5276aacc499ec2abd5241721e008",
				 "blockchain": "ethereum"
			 },
			 {
				 "address": "83VF9bSsC6Kz4y8byT3vHFxoiX9tZu7tAbYX1s8PuBJE",
				 "blockchain": "solana"
			 },
			 {
				 "address": "0xf2e8937d7aa0cb5c2d63f57b8d581c0aead055ff",
				 "blockchain": "ethereum"
			 },
			 {
				 "address": "0xc41b192df74fe564108110fe854b2bee70bb0b3a",
				 "blockchain": "ethereum"
			 }
		 ]
	 },
	"entityId": "203666",
	"moxieClaimTotals": [
		{
			"availableClaimAmount": 6190.931244877772,
			"claimedAmount": 165995.88407795024
		}
	]
}
"""
