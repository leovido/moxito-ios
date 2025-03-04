import SwiftUI

struct RewardCalculator {
	let totalRewardPool: Double = 20000.0
	let minimumSteps: Int = 2000

	// Weights for calories, distance, and heart rate contribution
	let caloriesWeight: Double = 0.5
	let distanceWeight: Double = 1.0
	let heartRateBonusWeight: Double = 2.0

	struct Participant {
		var steps: Int
		var caloriesBurned: Double
		var distanceTraveled: Double // in kilometers
		var heartRateBonus: Double // multiplier (e.g., 1.1 for high heart rate)
	}

	var participants: [Participant]

	// Calculate total score for all participants
	private var totalScore: Double {
		participants.filter { $0.steps >= minimumSteps }.reduce(0) { total, participant in
			total + calculateScore(for: participant)
		}
	}

	// Function to calculate the score for each participant
	private func calculateScore(for participant: Participant) -> Double {
		guard participant.steps >= minimumSteps else { return 0 }

		return Double(participant.steps)
		+ (participant.caloriesBurned * caloriesWeight)
		+ (participant.distanceTraveled * distanceWeight)
		+ (participant.heartRateBonus * heartRateBonusWeight)
	}

	// Function to calculate rewards for each participant
	func calculateRewards() -> [Double] {
		guard totalScore > 0 else {
			return participants.map { _ in 0 } // No rewards if no eligible steps
		}

		return participants.map { participant in
			let score = calculateScore(for: participant)
			let rewardShare = score / totalScore
			return rewardShare * totalRewardPool
		}
	}
}

struct AltRewardsView: View {
	@State private var participants: [RewardCalculator.Participant] = [
		.init(steps: 5000, caloriesBurned: 300, distanceTraveled: 4.0, heartRateBonus: 1.2),
		.init(steps: 8000, caloriesBurned: 450, distanceTraveled: 5.5, heartRateBonus: 1.3),
		.init(steps: 12000, caloriesBurned: 600, distanceTraveled: 7.5, heartRateBonus: 1.5)
	]

	@State private var userReward: Double = 0.0

	var body: some View {
		VStack {
			Text("Steps Today")
				.font(.headline)
				.padding()

			Button("Calculate Rewards") {
				// Calculate the rewards
				let rewardCalculator = RewardCalculator(participants: participants)
				let rewards = rewardCalculator.calculateRewards()

				// Assuming the current user is the second participant for simplicity
				userReward = rewards[1]
			}
			.padding()

			Text("Your Estimated Claimable $MOXIE: \(userReward, specifier: "%.2f")")
				.font(.largeTitle)
				.padding()
		}
	}
}

struct AltRewardsViewPreview: PreviewProvider {
	static var previews: some View {
		AltRewardsView()
	}
}
