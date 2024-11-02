//
//  Tests.swift
//  TipLibs
//
//  Created by Christian Ray Leovido on 01/11/2024.
//

import XCTest
@testable import MoxitoLib

final class MoxieClientTests: XCTestCase {
	var client: MoxitoClient!
	
	override func setUp() async throws {
		client = MoxitoClient()
	}
	
	override func tearDown() async throws {
		client = nil
	}
	
	func testFetchMoxieStats() async throws {
		let calendar = Calendar.current
		let startDate = calendar.date(from: DateComponents(year: 2024, month: 10, day: 21))!
		let endDate = calendar.date(from: DateComponents(year: 2024, month: 10, day: 28, hour: 23, minute: 59, second: 59))!
		
		let result = try await client
			.fetchAllCheckinsByUse(
				fid: 203666,
				startDate: startDate,
				endDate: endDate
			)
		
		XCTAssertEqual(result.first!.username, "leovido.eth")
	}
}
