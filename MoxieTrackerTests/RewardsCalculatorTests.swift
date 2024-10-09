//
//  RewardsCalculatorTests.swift
//  fc-poc-wf
//
//  Created by Christian Ray Leovido on 09/10/2024.
//

import XCTest
@testable import Moxito

final class RewardsCalculatorTests: XCTestCase {
	override func setUp() async throws {
		
	}
	
	override func tearDown() async throws {
		
	}
	
	func testCalculator() {
		let rewardCalculator = RewardCalculator(participants: [
			.init(steps: 10000, caloriesBurned: 2000, distanceTraveled: 23, heartRateBonus: 1.3),
			.init(steps: 5000, caloriesBurned: 2000, distanceTraveled: 23, heartRateBonus: 1.3),
			.init(steps: 10000, caloriesBurned: 2000, distanceTraveled: 23, heartRateBonus: 1.3),
			.init(steps: 2, caloriesBurned: 0, distanceTraveled: 0, heartRateBonus: 0),
			.init(steps: 10000, caloriesBurned: 2000, distanceTraveled: 23, heartRateBonus: 1.3),
			.init(steps: 10000, caloriesBurned: 2000, distanceTraveled: 23, heartRateBonus: 1.3),
			.init(steps: 10000, caloriesBurned: 2000, distanceTraveled: 23, heartRateBonus: 1.3),
			.init(steps: 10000, caloriesBurned: 2000, distanceTraveled: 23, heartRateBonus: 1.3),
			.init(steps: 10000, caloriesBurned: 2000, distanceTraveled: 23, heartRateBonus: 1.3),
			.init(steps: 10000, caloriesBurned: 2000, distanceTraveled: 23, heartRateBonus: 1.3),
		])
		
		let rewards = rewardCalculator.calculateRewards()
		
		XCTAssertEqual(rewards, [])
	}
}
