import XCTest
@testable import MoxieLib

final class MockClient: MoxieProvider {
	func fetchMoxieStats(userFID: Int) async throws -> MoxieLib.MoxieModel {
		.init(allEarningsAmount: 3, castEarningsAmount:2, frameDevEarningsAmount: 1, otherEarningsAmount: 0, endTimestamp: .now, startTimestamp: .now, timeframe: "", socials: [.init(isFarcasterPowerUser: true, profileImage: "", profileDisplayName: "Test", profileHandle: "@test")], entityID: "203666", moxieClaimTotals: [.init(availableClaimAmount: 10000, claimedAmount: 1000000)])
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
		let result = try await client.fetchMoxieStats(userFID: 203666)
		
		XCTAssertEqual(result.allEarningsAmount, 3)
	}
	
	func testFetchPrice() async throws {
		let result = try await client.fetchPrice()
		
		XCTAssertEqual(result, 0.0025)
	}
}
