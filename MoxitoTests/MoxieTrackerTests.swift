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
	
	let maxSteps = 10000.0
	let maxCalories = 500.0
	let maxHeartRateFluctuation = 40.0
	
	let userStepScore = Double(user.steps) / maxSteps * 0.5
	let userCalorieScore = Double(user.calories) / maxCalories * 0.3
	let userHeartRateScore = Double(user.heartRateFluctuation) / maxHeartRateFluctuation * 0.2
	let userTotalScore = userStepScore + userCalorieScore + userHeartRateScore
	
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

func calculateRewardPoints(activity: ActivityData) -> Decimal {
	let maxSteps: Decimal = 10000.0
	let maxCalories: Decimal = 500.0
	
	let stepPoints = (Decimal(activity.steps) / maxSteps) * stepWeight
	let caloriePoints = (activity.caloriesBurned / maxCalories) * calorieWeight
	let heartRatePoints = heartRateMultiplier(for: activity.avgHeartRate) * heartRateWeight * 1000
	
	let basePoints = stepPoints + caloriePoints + heartRatePoints
	
	return basePoints
}

func calculateRewardScore(steps: Int, caloriesBurned: Decimal, restingHeartRate: Decimal, tokensLocked: Decimal, maxSupply: Decimal) -> Decimal {
	// Base Activity Score (simplified here)
	let stepsWeight = Decimal(steps) * 0.5
	let caloriesWeight = caloriesBurned * 0.3
	let activityScore = stepsWeight + caloriesWeight + (restingHeartRate <= 60 ? 0.2 : 0.1)
	
	// Token Multiplier
//	let tokenMultiplier = dynamicTokenMultiplier(for: tokensLocked, currentAvailableSupply: 5000, maxSupply: maxSupply)
	
	let aggregatedScore = activityScore
	return aggregatedScore
}

@MainActor
final class MoxitoTests: XCTestCase {
	var viewModel: StepCountViewModel!
	
	override func setUpWithError() throws {
		viewModel = .init()
	}
	
	override func tearDownWithError() throws {
		viewModel = nil
	}
	
	func testCalculateRewardPoints() throws {
		let activity: Moxito.ActivityData = .init(steps: 10000, caloriesBurned: 500, distance: 50, avgHeartRate: 0)
		let score = viewModel.calculateRewardPoints(activity: activity)
		
		XCTAssertEqual(score, 38.160704749987004416)
	}
	
	func testCalculateRewardPoints2() throws {
		let activity: Moxito.ActivityData = .init(steps: 10000, caloriesBurned: 500, distance: 50, avgHeartRate: 60)
		let score = viewModel.calculateRewardPoints(activity: activity)
		
		XCTAssertEqual(score, 38.160704749987004416)
	}
	
	func testCalculateRewardPointsMax() throws {
		let activity: Moxito.ActivityData = .init(steps: 10000, caloriesBurned: 500, distance: 50, avgHeartRate: 130)
		viewModel.averageHeartRate = 190
		let score = viewModel.calculateRewardPoints(activity: activity)
		
		XCTAssertEqual(score, 127.6525001442312192)
	}
	
	func testCalculateRewardPointsArob() throws {
		let activity: Moxito.ActivityData = .init(steps: 25000, caloriesBurned: 1200, distance: 19.3, avgHeartRate: 130)
		let score = viewModel.calculateRewardPoints(activity: activity)
		
		XCTAssertEqual(score, 600.7)
	}
	
	func testCalculateRewardPointsMax2() throws {
		let activity: Moxito.ActivityData = .init(steps: 10000, caloriesBurned: 600, distance: 50, avgHeartRate: 130)
		let score = viewModel.calculateRewardPoints(activity: activity)
		
		XCTAssertEqual(score, 127.7185001442312192)
	}
	
	func testCalculateRewardPointsAverage() throws {
		let activity: Moxito.ActivityData = .init(steps: 10000, caloriesBurned: 500, distance: 50, avgHeartRate: 90)
		let score = viewModel.calculateRewardPoints(activity: activity)
		
		XCTAssertEqual(score, 63.2668811667587584)
	}
	
	func testCalculateRewardPoints20K() throws {
		let activity: Moxito.ActivityData = .init(steps: 20000, caloriesBurned: 1200, distance: 50, avgHeartRate: 90)
		let score = viewModel.calculateRewardPoints(activity: activity)
		
		XCTAssertGreaterThanOrEqual(score, 64.4548811667587584)
	}
	
	func testCalculateRewardPointsCustom() throws {
		let activity: Moxito.ActivityData = .init(steps: 8400, caloriesBurned: 541, distance: 6.4, avgHeartRate: 90)
		let score = viewModel.calculateRewardPoints(activity: activity)
		
		XCTAssertEqual(score, 54.4959411667587584)
	}
	
	func testCalculateRewardPointsLessSteps() throws {
		let activity: Moxito.ActivityData = .init(steps: 2000, caloriesBurned: 40, distance: 0.02, avgHeartRate: 80)
		viewModel.averageHeartRate = 60
		let score = viewModel.calculateRewardPoints(activity: activity)
		
		XCTAssertEqual(score, 27.58870474998700544)
	}
	
	func testCalculateRewardPointsLessSteps4000() throws {
		let activity: Moxito.ActivityData = .init(steps: 4000, caloriesBurned: 40, distance: 0.02, avgHeartRate: 80)
		viewModel.averageHeartRate = 60
		let score = viewModel.calculateRewardPoints(activity: activity)
		
		XCTAssertEqual(score, 27.64870474998700544)
	}
	
	func testCalculateRewardPointsLessSteps6000() throws {
		let activity: Moxito.ActivityData = .init(steps: 11000, caloriesBurned: 500, distance: 0.02, avgHeartRate: 80)
		viewModel.averageHeartRate = 60
		let score = viewModel.calculateRewardPoints(activity: activity)
		
		XCTAssertEqual(score, 28.19770474998700032)
	}
	
	func testCalculateRewardPointsAveragePlus() throws {
		let activity: Moxito.ActivityData = .init(steps: 20000, caloriesBurned: 500, distance: 50, avgHeartRate: 80)
		viewModel.averageHeartRate = 121
		let score = viewModel.calculateRewardPoints(activity: activity)
		
		XCTAssertEqual(score, 38.67070474998700544)
	}
	
	func testCalculateRewardPointsHRNone() throws {
		let activity: Moxito.ActivityData = .init(steps: 20000, caloriesBurned: 500, distance: 50, avgHeartRate: 80)
		viewModel.averageHeartRate = 60
		let score = viewModel.calculateRewardPoints(activity: activity)
		
		XCTAssertEqual(score, 38.67070474998700544)
	}
	
	func testDynamicTokenMultiplier() throws {
		let currentAvailableSupply: Decimal = 5000
		let maxSupply: Decimal = 8070.985
		
		let multiplier: Decimal = dynamicTokenMultiplier(for: 1000, currentAvailableSupply: currentAvailableSupply, maxSupply: maxSupply)
		XCTAssertGreaterThanOrEqual(multiplier, 1.030702724478163778380977515172808)
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
		
		XCTAssertEqual(rewardPoints, 5150.10)
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
		
		XCTAssertEqual(user1Reward, 1774.1935483870966)
		XCTAssertEqual(user2Reward, 3064.516129032258)
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
