import SwiftUI
import MoxieLib

struct RewardsView: View {
	@Environment(\.locale) var locale
	@StateObject var viewModel: StepCountViewModel = .init(steps: 7000, caloriesBurned: 2432, distanceTraveled: 30, restingHeartRate: 60)
	@EnvironmentObject var mainViewModel: MoxieViewModel
	@State private var isBeating = false // State variable for heart animation

	var distance1: Measurement<UnitLength> {
		return Measurement(value: Double(truncating: viewModel.distanceTraveled as NSNumber), unit: UnitLength.kilometers)
	}

	// Compute the heartbeat interval based on the resting heart rate (in seconds)
	var heartbeatInterval: Double {
		let bpm = viewModel.restingHeartRate
		if bpm > 0 {
			return Double(truncating: 60.0 / bpm as NSNumber)
		} else {
			return 1.0
		}
	}

	var body: some View {
		NavigationStack {
			GeometryReader { _ in
				ZStack {
					Color(uiColor: MoxieColor.primary)
						.ignoresSafeArea()
					Image("wave", bundle: .main)
						.resizable()
						.ignoresSafeArea()

					VStack {
						HStack {
							VStack(alignment: .leading) {
								Text("Hello, " + (mainViewModel.model.socials.first?.profileDisplayName ?? "Moxie"))
									.scaledToFit()
									.font(.body)
									.font(.custom("Inter", size: 20))
									.foregroundStyle(Color.white)
									.fontWeight(.bold)
									.multilineTextAlignment(.leading)
								Text("Last update: \(mainViewModel.timeAgo)")
									.fontWeight(.light)
									.foregroundStyle(Color.white)
									.font(.caption)
									.font(.custom("Inter", size: 20))
									.multilineTextAlignment(.leading)
							}
							Spacer()

							Button(action: {

							}, label: {
								Text("Claimed")
									.foregroundStyle(.white)
									.padding(16)
							})
							.frame(minWidth: 102)
							.frame(height: 38)
							.font(.callout)
							.background(Color(uiColor: MoxieColor.claimButton))
							.clipShape(Capsule())

							NavigationLink {
								AccountView()
							} label: {
								Image("GearUnselected")
									.resizable()
									.renderingMode(.template)
									.aspectRatio(contentMode: .fit)
									.frame(width: 20, height: 20)
									.foregroundStyle(Color(uiColor: MoxieColor.primary))
							}
							.frame(width: 38, height: 38)
							.font(.callout)
							.background(Color.white)
							.clipShape(Circle())

						}
						.padding(.bottom, 20)

						ScrollView {
							VStack {
								HStack {
									Image(systemName: "figure.walk")
										.foregroundColor(Color(uiColor: MoxieColor.green))
									Text("Steps today")
										.font(.headline)
										.foregroundColor(Color(uiColor: MoxieColor.primary))
								}

								HStack {
									Text("\(viewModel.steps.formatted(.number.precision(.fractionLength(0))))")
										.font(.system(size: 40, weight: .bold))
										.foregroundColor(Color(uiColor: MoxieColor.primary))
									Text("/ 10,000")
										.font(.title3)
										.foregroundColor(.gray)
								}

								ProgressView(value: Double(truncating: viewModel.steps as NSNumber), total: Double(10000))
									.progressViewStyle(LinearProgressViewStyle(tint: Color(uiColor: MoxieColor.green)))
									.padding(.horizontal, 50)

								VStack(alignment: .center, spacing: 8) {
									Text("Estimated claimable $MOXIE")
										.font(.headline)
										.foregroundColor(Color(uiColor: MoxieColor.primary))
									HStack {
										Text("\(Int(5000), format: .number)")
											.font(.custom("Inter", size: 30))
											.foregroundColor(Color(uiColor: MoxieColor.primary))
											.bold()

										Image("CoinMoxiePurple")
											.resizable()
											.aspectRatio(contentMode: .fit)
											.frame(width: 20)
											.foregroundColor(Color(uiColor: MoxieColor.primary))
									}
								}
								.padding(.top)
							}
							.padding(.vertical, 20)
							.background(Color.white)
							.clipShape(RoundedRectangle(cornerRadius: 24))
							.padding(.bottom)

							FitnessCardView(imageSystemName: "flame.fill", title: "Calories burned", amount: viewModel.caloriesBurned, type: .calories)

							FitnessCardView(imageSystemName: "location.fill", title: "Distance travelled", amount: viewModel.distanceTraveled, type: .distance)

							FitnessCardView(imageSystemName: "heart.fill", title: "Resting heart rate", amount: viewModel.restingHeartRate, noFormatting: true, type: .heartRate)

							Spacer()
						}
					}
					.padding()
				}
			}
		}
	}
}

struct RewardsView_Previews: PreviewProvider {
	static var previews: some View {
		RewardsView()
			.environmentObject(MoxieViewModel())
	}
}
