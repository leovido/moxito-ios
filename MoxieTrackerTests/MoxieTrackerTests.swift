import XCTest
@testable import Moxito
import MoxieLib

struct Participant {
		var steps: Int
		var calories: Int
		var heartRateFluctuation: Int
}

// Function to calculate the reward for a single user
func calculateReward(for user: Participant, participants: [Participant], totalPrize: Double) -> Double {
	
	// Maximum values for scaling purposes
	let maxSteps = 10000.0
	let maxCalories = 500.0
	let maxHeartRateFluctuation = 40.0
	
	// Calculate user's score based on steps, calories, and heart rate fluctuation
	let userStepScore = Double(user.steps) / maxSteps * 0.5
	let userCalorieScore = Double(user.calories) / maxCalories * 0.3
	let userHeartRateScore = Double(user.heartRateFluctuation) / maxHeartRateFluctuation * 0.2
	let userTotalScore = userStepScore + userCalorieScore + userHeartRateScore
	
	// Calculate the total score for all participants
	let totalEffort = participants.reduce(0.0) { total, participant in
		let stepScore = Double(participant.steps) / maxSteps * 0.5
		let calorieScore = Double(participant.calories) / maxCalories * 0.3
		let heartRateScore = Double(participant.heartRateFluctuation) / maxHeartRateFluctuation * 0.2
		return total + stepScore + calorieScore + heartRateScore
	}
	
	// Calculate the user's proportion of the total effort
	let userRewardProportion = userTotalScore / totalEffort
	
	// User's reward is a portion of the total prize
	let userReward = userRewardProportion * totalPrize
	
	return userReward
}


final class MoxieTrackerTests: XCTestCase {
	
	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}
	
	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}
	
	func testRewardCalculation() throws {
		let participants: [Participant] = [
			.init(steps: 1000, calories: 200, heartRateFluctuation: 10),
			.init(steps: 2000, calories: 300, heartRateFluctuation: 20),
			.init(steps: 3000, calories: 400, heartRateFluctuation: 50)
		]
		
		let totalPrize: Double = 10000.0
		
		let user1Reward: Double = calculateReward(for: participants[0],
																							participants: participants,
																							totalPrize: totalPrize)
		let user2Reward: Double = calculateReward(for: participants[1], participants: participants, totalPrize: totalPrize)
		
		XCTAssertEqual(user1Reward, 1000.0)
		XCTAssertEqual(user2Reward, 2000.0)
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
