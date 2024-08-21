import XCTest
@testable import TipLibs

final class MockClient: TipProvider {
	func fetchFartherTips(forceRemote: Bool) async throws -> TipModel {
		return TipModel(id: UUID(),
										allowance: 10_000,
										given: 5_000,
										received: 200_000,
										balance: String(Int.random(in: 100...10_000_000)),
										tipMin: 200,
										rank: 20)
	}
}

final class TipTests: XCTestCase {
	var client: TipProvider!
	
	override func setUp() async throws {
		client = MockClient()
	}
	
	override func tearDown() async throws {
		client = nil
	}
	
	func testFartherTips() async throws {
		let result = try await client.fetchFartherTips(forceRemote: false)
		
		XCTAssertEqual(result.allowance, 10000)
		XCTAssertEqual(result.rank, 20)
	}
}

final class LiveTipTests: XCTestCase {
	var client: TipProvider!
	
	override func setUp() async throws {
		client = TipClient()
	}
	
	override func tearDown() async throws {
		client = nil
	}
	
	func testFartherTips() async throws {
		let result = try await client.fetchFartherTips(forceRemote: false)
		
		XCTAssertEqual(result.allowance, 10000)
		XCTAssertEqual(result.rank, 20)
	}
}
