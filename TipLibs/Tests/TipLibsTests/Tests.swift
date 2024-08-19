import XCTest
@testable import TipLibs

final class MockClient: TipProvider {
	func fetchFartherTips() async throws -> TipModel {
		return TipModel(id: UUID(),
										allowance: 10_000,
										given: 5_000,
										received: 200_000,
										balance: String(Int.random(in: 100...10_000_000)),
										tipMin: 200,
										rank: 20)
	}
}

final class TipDependenciesTests: XCTestCase {
	var client: TipProvider!
	
	override func setUp() async throws {
		client = MockClient()
	}
	
	override func tearDown() async throws {
		client = nil
	}
	
	func testExample() async throws {
		let result = try await client.fetchFartherTips()
		
		XCTAssertEqual(result.allowance, 10000)
		XCTAssertEqual(result.rank, 20)
	}
}
