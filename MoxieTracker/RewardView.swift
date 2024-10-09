import SwiftUI
import MoxieLib

struct RewardsView: View {
	@Environment(\.locale) var locale
	@StateObject var viewModel: StepCountViewModel = .init()
	@EnvironmentObject var mainViewModel: MoxieViewModel
	@State private var isBeating = false // State variable for heart animation

	var distance1: Measurement<UnitLength> {
		return Measurement(value: viewModel.distanceTraveled, unit: UnitLength.kilometers)
	}

	// Compute the heartbeat interval based on the resting heart rate (in seconds)
	var heartbeatInterval: Double {
		let bpm = viewModel.restingHeartRate
		if bpm > 0 {
			return 60.0 / bpm // 60 seconds divided by beats per minute (bpm) gives the interval for one beat
		} else {
			return 1.0 // Default to 1 second if no bpm data available
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

							Button(action: {

							}, label: {
								Image(systemName: "gear")
									.resizable()
									.aspectRatio(contentMode: .fit)
									.frame(width: 20, height: 20)
									.foregroundStyle(Color(uiColor: MoxieColor.primary))
							})
							.frame(width: 38, height: 38)
							.font(.callout)
							.background(Color.white)
							.clipShape(Circle())
						}
						.padding(.bottom, 20)

						Spacer()
					}
					.padding(.horizontal)

					ScrollView {
						VStack(spacing: 40) {
							Spacer().frame(height: 20)

							// Header section
							Text("Daily Rewards")
								.font(.largeTitle)
								.fontWeight(.bold)
								.foregroundColor(.white)
								.padding()

							// Steps section
							HStack {
								Image(systemName: "figure.walk")
									.foregroundColor(Color(uiColor: MoxieColor.green))
								VStack(alignment: .leading) {
									Text("Steps today")
										.font(.headline)
										.foregroundColor(.white)
									HStack {
										Text("\(viewModel.steps.formatted(.number.precision(.fractionLength(0))))")
											.font(.system(size: 40, weight: .bold))
											.foregroundColor(.white)
										Text("/ 10,000")
											.font(.title3)
											.foregroundColor(.gray)
									}
								}
							}
							.padding(.horizontal)
							ProgressView(value: Double(viewModel.steps), total: Double(10000))
								.progressViewStyle(LinearProgressViewStyle(tint: Color(uiColor: MoxieColor.green)))
								.padding(.horizontal, 50)

							VStack(alignment: .center) {
								Text("Estimated claimable $MOXIE")
									.font(.headline)
									.foregroundColor(Color(uiColor: MoxieColor.primary))
								HStack {

									Text("\(Int(20000), format: .number)")
										.font(.system(size: 40, weight: .bold))
										.foregroundColor(Color(uiColor: MoxieColor.primary))

									Image("CoinMoxiePurple")
										.resizable()
										.aspectRatio(contentMode: .fit)
										.frame(width: 30)
										.foregroundColor(Color(uiColor: MoxieColor.primary))
								}
							}
							.padding(.horizontal)

							// Calories section
							HStack {
								Image(systemName: "flame.fill")
									.foregroundColor(.red)
								VStack(alignment: .leading) {
									Text("Calories burned")
										.font(.headline)
										.foregroundColor(Color(uiColor: MoxieColor.primary))
									Text("\(viewModel.caloriesBurned, specifier: "%.0f") kcal")
										.font(.system(size: 40, weight: .bold))
										.foregroundColor(.red)
								}
							}
							.padding(.horizontal)

							// Distance traveled section
							HStack {
								Image(systemName: "location.fill")
									.foregroundColor(Color.purple)
								VStack(alignment: .leading) {
									Text("Distance traveled")
										.font(.headline)
										.foregroundColor(Color(uiColor: MoxieColor.primary))
									Text(distance1.formatted(
										.measurement(width: .abbreviated, usage: .asProvided, numberFormatStyle: .number.precision(.fractionLength(2)))
										.locale(locale)
									))
									.font(.system(size: 40, weight: .bold))
									.foregroundColor(Color.purple)
								}
							}
							.padding(.horizontal)

							// Resting heart rate section with dynamic heartbeat animation
							VStack {
								HStack {
									Image(systemName: "heart.fill")
										.symbolRenderingMode(.palette)
										.foregroundStyle(Color.pink, Color.red)
										.font(.system(size: 30))
										.scaleEffect(isBeating ? 1.2 : 1.0) // Heartbeat animation scale effect
										.animation(Animation.easeInOut(duration: heartbeatInterval).repeatForever(autoreverses: true), value: isBeating) // Animate the scale effect based on heart rate
										.onAppear {
											isBeating = true // Start beating when the view appears
										}
									Text("Resting Heart Rate")
										.font(.headline)
										.foregroundColor(Color(uiColor: MoxieColor.primary))
								}

								Text("\(Int(viewModel.restingHeartRate)) bpm")
									.font(.system(size: 40, weight: .bold))
									.foregroundColor(Color(uiColor: MoxieColor.primary))

								Spacer()
							}
						}
					}
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
