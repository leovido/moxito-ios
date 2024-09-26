import XCTest
@testable import Moxito
import MoxieLib

final class MoxieTrackerTests: XCTestCase {
	
	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}
	
	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}
	
	func testLocalUK() throws {
		let current = formattedDollarValue(dollarValue: 1234.231243, locale: .init(components: .init(identifier: "en_GB")))
		let expected = "$1,234.23"
		
		XCTAssertEqual(current, expected)
	}
	
	func testLocaleUS() throws {
		let current = formattedDollarValue(dollarValue: 1234.231243, locale: .init(components: .init(identifier: "en_US")))
		let expected = "$1,234.23"
		
		XCTAssertEqual(current, expected)
	}
	
	func testLocaleJP() throws {
		let current = formattedDollarValue(dollarValue: 1234.231243, locale: .init(components: .init(identifier: "ja_JP")))
		let expected = "$1,234.23"
		
		XCTAssertEqual(current, expected)
	}
	
	func testRounding() throws {
		let current = formattedDollarValue(dollarValue: 32.199)
		let expected = "$32.20"
		
		XCTAssertEqual(current, expected)
	}
	
	func testRoundingBiggerDecimal() throws {
		let current = formattedDollarValue(dollarValue: 32.1999999999999)
		let expected = "$32.20"
		
		XCTAssertEqual(current, expected)
	}
	
	func testBiggerValue() throws {
		let current = formattedDollarValue(dollarValue: 12344325343.231243)
		let expected = "$12,344,325,343.23"
		
		XCTAssertEqual(current, expected)
	}
}
