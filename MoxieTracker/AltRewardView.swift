// import SwiftUI
//
// struct RewardView: View {
//	var rewardCalculator = RewardCalculator()
//
//	var body: some View {
//		VStack(spacing: 20) {
//			// Step Input
//			VStack {
//				Text("Steps walked:")
//				TextField("Steps", value: $rewardCalculator.steps, format: .number)
//					.textFieldStyle(RoundedBorderTextFieldStyle())
//					.padding()
//			}
//
//			// Daily Streak Input
//			VStack {
//				Text("Daily Streak:")
//				TextField("Streak", value: $rewardCalculator.dailyStreak, format: .number)
//					.textFieldStyle(RoundedBorderTextFieldStyle())
//					.padding()
//			}
//
//			// Calories Burned Input
//			VStack {
//				Text("Calories Burned:")
//				TextField("Calories", value: $rewardCalculator.caloriesBurned, format: .number)
//					.textFieldStyle(RoundedBorderTextFieldStyle())
//					.padding()
//			}
//
//			// Distance Traveled Input
//			VStack {
//				Text("Distance Traveled (in km):")
//				TextField("Distance", value: $rewardCalculator.distanceTraveled, format: .number)
//					.textFieldStyle(RoundedBorderTextFieldStyle())
//					.padding()
//			}
//
//			// Heart Rate Bonus Input
//			VStack {
//				Text("Heart Rate Bonus:")
//				TextField("Heart Rate", value: $rewardCalculator.heartRateBonus, format: .number)
//					.textFieldStyle(RoundedBorderTextFieldStyle())
//					.padding()
//			}
//
//			// Morning Walk Bonus Toggle
//			Toggle(isOn: $rewardCalculator.isMorningWalk) {
//				Text("Morning Walk Bonus")
//			}
//			.padding()
//
//			// Calculate Button
//			Button(action: {
//				rewardCalculator.calculateRewards()
//			}) {
//				Text("Calculate Rewards")
//					.padding()
//					.background(Color.blue)
//					.foregroundColor(.white)
//					.cornerRadius(8)
//			}
//
//			// Display the Total Reward
//			Text("Total $MOXIE Earned: \(rewardCalculator.totalReward, specifier: "%.2f")")
//				.font(.body)
//				.padding()
//		}
//		.padding()
//	}
// }
//
// #Preview {
//	RewardView(rewardCalculator: .init())
// }
