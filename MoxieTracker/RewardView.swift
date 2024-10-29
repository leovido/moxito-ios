import SwiftUI
import MoxieLib

struct RewardsView: View {
	@Environment(\.locale) var locale
	@StateObject var viewModel: StepCountViewModel = .init()

	@EnvironmentObject var claimViewModel: MoxieClaimViewModel
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

	var rewardsUSD: Decimal {
		mainViewModel.totalPoolRewards * mainViewModel.price
	}

	var body: some View {
		NavigationStack {
			GeometryReader { geo in
				ZStack {
					Color(uiColor: MoxieColor.primary)
						.ignoresSafeArea()
					Image("wave", bundle: .main)
						.resizable()
						.ignoresSafeArea()

					VStack {
						HeaderView(tab: .fitness)

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
									Text("Total pool rewards in $MOXIE")
										.font(.headline)
										.foregroundColor(Color(uiColor: MoxieColor.primary))
									HStack {
										Text(mainViewModel.totalPoolRewards.formatted(.number.precision(.fractionLength(0))))
											.font(.custom("Inter", size: 30))
											.foregroundColor(Color(uiColor: MoxieColor.primary))
											.bold()

										Image("CoinMoxiePurple")
											.resizable()
											.aspectRatio(contentMode: .fit)
											.frame(width: 20)
											.foregroundColor(Color(uiColor: MoxieColor.primary))
									}

									Text("~\(formattedDollarValue(dollarValue: rewardsUSD))")
										.font(.custom("Inter", size: 13))
										.foregroundColor(Color(uiColor: MoxieColor.primary))
										.padding(.top, -8)
								}
								.padding(.top)
							}
							.padding(.vertical, 20)
							.background(Color.white)
							.clipShape(RoundedRectangle(cornerRadius: 24))
							.padding(.bottom)

							FitnessCardView(imageSystemName: "flame.fill", title: "Calories burned", amount: viewModel.caloriesBurned, type: .calories)

							FitnessCardView(imageSystemName: "location.fill", title: "Distance travelled", amount: viewModel.distanceTraveled, type: .distance)

							FitnessCardView(imageSystemName: "heart.fill", title: "Average workout HR", amount: viewModel.averageHeartRate, noFormatting: true, type: .heartRate)

							Spacer()
						}
					}
					.refreshable {
						Task {
							viewModel.fetchHealthData()
							try await mainViewModel.fetchTotalPoolRewards()
						}
					}
					.padding()
					.confirmationDialog("Moxie claim",
															isPresented: $claimViewModel.isClaimDialogShowingRewards,
															titleVisibility: .visible) {
						ForEach(mainViewModel.wallets, id: \.self) { wallet in
							Button(wallet) {
								claimViewModel.actions.send(.selectedWallet(wallet))
							}
						}
					} message: {
						Text("Choose wallet for claiming Moxie")
					}
					.overlay(alignment: .center, content: {
						if claimViewModel.isClaimRequested {
							VStack {
								ProgressView(value: claimViewModel.progress, total: 1.0)
									.progressViewStyle(LinearProgressViewStyle())
									.tint(Color(uiColor: MoxieColor.green))
									.padding()
									.onAppear {
										claimViewModel.startProgressTimer()
									}
									.onDisappear {
										claimViewModel.stopProgressTimer()
									}

								Text("Claiming... \(Int(claimViewModel.progress * 100))%")
									.font(.custom("Inter", size: 23))
									.padding()
									.foregroundStyle(Color.white)

								Button {
									withAnimation {
										if Int(claimViewModel.progress * 100) == 100 {
											claimViewModel.actions.send(.dismissClaimAlert)
										} else {
											let transactionId = claimViewModel.moxieClaimModel?.transactionID ?? ""
											claimViewModel.actions.send(.checkClaimStatus(fid: mainViewModel.model.entityID, transactionId: transactionId))
										}
									}
								} label: {
									Text(Int(claimViewModel.progress * 100) == 100 ? "Done" : "Refresh")
										.font(.custom("Inter", size: 18))
										.padding()
										.foregroundStyle(Color.white)
								}
								.frame(minWidth: 102)
								.frame(height: 38)
								.background(Int(claimViewModel.progress * 100) == 100 ? Color(uiColor: MoxieColor.green) : Color(uiColor: MoxieColor.primary))
								.clipShape(Capsule())
							}
							.frame(height: geo.size.height)
							.background(Color(uiColor: MoxieColor.primary).opacity(0.8))
							.transition(.opacity)
						}
					})
				}
				.onAppear {

					viewModel.createActivityData { result in
						dump(result)
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
			.environmentObject(MoxieClaimViewModel())
	}
}
