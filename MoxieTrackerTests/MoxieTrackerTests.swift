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

struct ActivityData {
	var steps: Int
	var caloriesBurned: Decimal
	var avgHeartRate: Decimal
	var tokensLocked: Decimal
}

// Weights for activity metrics
let stepWeight: Decimal = 0.4
let calorieWeight: Decimal = 0.3
let heartRateWeight: Decimal = 0.3

// Heart rate zone multiplier
func heartRateMultiplier(for avgHeartRate: Decimal) -> Decimal {
	switch avgHeartRate {
	case 90...120: return 1.0
	case 121...150: return 1.5
	case 151...180: return 2.0
	default: return 1.0
	}
}

// Dynamic token multiplier based on available supply
func dynamicTokenMultiplier(for tokensLocked: Decimal, currentAvailableSupply: Decimal, maxSupply: Decimal) -> Decimal {
	let baseMultiplier: Decimal = 1.0       // Minimum multiplier
		let maxMultiplierFactor: Decimal = 2.0  // Max multiplier when locking a large portion of the supply
		
		// Calculate the proportion of maxSupply that is locked
		let lockedProportion = tokensLocked / maxSupply
		
		// Non-linear scaling factor: higher impact for larger locked proportions
		let scalingFactor = lockedProportion * lockedProportion
		
		// Final multiplier calculation, with scaling applied
		let adjustedMultiplier = baseMultiplier + (scalingFactor * maxMultiplierFactor)
		
		// Optional: If locking more than a specific threshold, apply a boost
		let largeLockBonus = tokensLocked > 1000 ? adjustedMultiplier * 1.1 : adjustedMultiplier
		
		return largeLockBonus
}

// Calculate reward points
func calculateRewardPoints(activity: ActivityData, currentAvailableSupply: Decimal, maxSupply: Decimal) -> Decimal {
	let stepPoints = Decimal(activity.steps) * stepWeight
	let caloriePoints = activity.caloriesBurned * calorieWeight
	let heartRatePoints = heartRateMultiplier(for: activity.avgHeartRate) * heartRateWeight * 1000
	
	let basePoints = stepPoints + caloriePoints + heartRatePoints
	
	let tokenBonus = dynamicTokenMultiplier(for: activity.tokensLocked, currentAvailableSupply: currentAvailableSupply, maxSupply: maxSupply)
	
	return basePoints * tokenBonus
}

func calculateRewardScore(steps: Int, caloriesBurned: Decimal, restingHeartRate: Decimal, tokensLocked: Decimal, maxSupply: Decimal) -> Decimal {
		// Base Activity Score (simplified here)
	let stepsWeight = Decimal(steps) * 0.5
	let caloriesWeight = caloriesBurned * 0.3
		let activityScore = stepsWeight + caloriesWeight + (restingHeartRate > 60 ? 0.2 : 0.1)
		
		// Token Multiplier
		let tokenMultiplier = dynamicTokenMultiplier(for: tokensLocked, currentAvailableSupply: 5000, maxSupply: maxSupply)

		// Aggregate the score
		let aggregatedScore = activityScore * tokenMultiplier
		return aggregatedScore
}



final class MoxieTrackerTests: XCTestCase {
	
	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}
	
	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}
	
	func testNewRewardCalculation() throws {
		// Example usage
		let maxSupply: Decimal = 8070.985
		let todayActivity = ActivityData(steps: 10000, caloriesBurned: 500, avgHeartRate: 130, tokensLocked: 1000)
		
		let rewardPoints = calculateRewardScore(steps: todayActivity.steps,
																						caloriesBurned: todayActivity.caloriesBurned,
																						restingHeartRate: todayActivity.avgHeartRate,
																						tokensLocked: todayActivity.tokensLocked,
																						maxSupply: maxSupply)
		
		XCTAssertEqual(rewardPoints, 0)
		print("Reward Points for today: \(rewardPoints)")
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
