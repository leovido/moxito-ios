import SwiftUI
import MoxieLib

struct RewardsView: View {
	@Environment(\.locale) var locale
	@EnvironmentObject var viewModel: StepCountViewModel

	@EnvironmentObject var claimViewModel: MoxieClaimViewModel
	@EnvironmentObject var mainViewModel: MoxieViewModel
	@State private var isBeating = false // State variable for heart animation

	var isFitnessRewardsPaused: Bool {
		let calendar = Calendar.current
		let startDate = calendar.date(from: DateComponents(year: 2024, month: 11, day: 11))!

		return startDate >= Date()
	}

	let textOptionsCheckinShare: [String] = [
		"Earning $MOXIE rewards today for staying active!\n\nChecking in with Moxito for my steps and fitness progress.\n\ncc: @moxito 🌱",

		"Today’s check-in with Moxito for fitness rewards!\n\nLogging my steps and making my fitness count. Let’s go! 💪\n\ncc: @moxito🌱",

		"Another day, another check-in!\n\nTracking my steps and fitness for $MOXIE rewards with Moxito.\n\ncc: @moxito🌱",

		"Fitness rewards on!\n\nChecking in with Moxito today to log my progress and earn some $MOXIE!\n\ncc: @moxito🌱",

		"Checking in with Moxito for daily $MOXIE rewards!\n\nMaking every step count towards my fitness goals.\n\ncc: @moxito🌱"
	]

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

						if viewModel.didAuthorizeHealthKit {
							ScrollView(showsIndicators: false) {
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
										Text("/ \(viewModel.stepsLimit.formatted(.number.precision(.fractionLength(0))))")
											.font(.title3)
											.foregroundColor(.gray)
									}

									ProgressView(value: Double(truncating: viewModel.steps as NSNumber), total: Double(truncating: viewModel.stepsLimit as NSNumber))
										.progressViewStyle(LinearProgressViewStyle(tint: Color(uiColor: MoxieColor.green)))
										.padding(.horizontal, 50)

									VStack(alignment: .center, spacing: 8) {
										if !isFitnessRewardsPaused {
											Text("Total pool rewards in $MOXIE")
												.font(.footnote)
												.font(.custom("Inter", size: 13))
											HStack {
												Text(mainViewModel.totalPoolRewards.formatted(.number.precision(.fractionLength(0))))
													.font(.largeTitle)
													.font(.custom("Inter", size: 30))
													.foregroundStyle(Color(uiColor: MoxieColor.primary))
													.fontWeight(.heavy)

												Image("CoinMoxiePurple")
													.resizable()
													.aspectRatio(contentMode: .fit)
													.frame(width: 20)
													.foregroundColor(Color(uiColor: MoxieColor.primary))
											}

											Text("~\(formattedDollarValue(dollarValue: rewardsUSD))")
												.font(.caption)
												.font(.custom("Inter", size: 12))
												.foregroundStyle(Color(uiColor: MoxieColor.primary))
												.padding(.top, -4)
										} else {
											Text("Fitness rewards paused until the 11th")
												.font(.footnote)
												.font(.custom("Inter", size: 13))
												.foregroundColor(Color(uiColor: MoxieColor.primary))

											Text("If you see \"Synced\" at the bottom of this view, your scores are up to date for fitness rewards. You'll receive a DM with further instructions once everyone is fully synced.")
												.font(.footnote)
												.padding(.horizontal)
												.multilineTextAlignment(.center)
												.font(.custom("Inter", size: 13))
												.foregroundColor(Color(uiColor: MoxieColor.primary))

											Button {
												if !viewModel.scores.isEmpty {
													viewModel.actions.send(.presentScoresView)
												}
											} label: {
												Text("View scores")
													.foregroundStyle(Color.white)
													.padding(.horizontal)
											}
											.disabled(!viewModel.isInSync)
											.padding(8)
											.background(
													Color(uiColor: viewModel.checkins.contains {
															Calendar.current.isDateInToday($0.createdAt)
													} ? MoxieColor.green : MoxieColor.primary)
											)
											.clipShape(RoundedRectangle(cornerRadius: 24))
											.padding(.top, 4)

											HStack {
												Text(viewModel.isInSync ? "Synced" : "Syncing...")
													.foregroundStyle(Color(uiColor: MoxieColor.primary))
													.padding(.horizontal)
													.font(.custom("Inter", size: 11))

												Image(systemName: viewModel.isInSync ? "checkmark.circle.fill" : "circle")
													.foregroundStyle(Color(uiColor: MoxieColor.green))
											}
										}

									}
									.padding(.top)
								}
								.padding(.vertical, 20)
								.background(Color.white)
								.clipShape(RoundedRectangle(cornerRadius: 24))

								HStack {
									Text("Check in via frame in Warpcast")
										.font(.footnote)
										.font(.custom("Inter", size: 13))
										.foregroundColor(Color(uiColor: MoxieColor.primary))
										.padding(.leading)

									Spacer()

									Link(destination: URL(string: "https://warpcast.com/~/compose?text=\(textOptionsCheckinShare.randomElement()!)&embeds[]=https://moxito.xyz/fitnessRewards")!, label: {
										Text("Check in")
											.foregroundStyle(Color.white)
											.padding(.horizontal)
									})
										.padding(8)
										.background(
												Color(uiColor: viewModel.checkins.contains {
														Calendar.current.isDateInToday($0.createdAt)
												} ? MoxieColor.green : MoxieColor.primary)
										)
										.clipShape(RoundedRectangle(cornerRadius: 24))
								}
								.padding(6)
								.background(Color.white)
								.clipShape(RoundedRectangle(cornerRadius: 14))

								SwipeableWeekView()

								HStack {
									Spacer()

									Button {
										viewModel.filterSelection = 0
									} label: {
										Text("Day")
											.foregroundStyle(viewModel.filterSelection == 0 ? Color.white : Color(uiColor: MoxieColor.grayPickerText))
											.font(.custom("Inter", size: 14))
									}
									.frame(width: geo.size.width / 4)
									.padding(4)
									.background(viewModel.filterSelection == 0 ? Color(uiColor: MoxieColor.green) : .clear)
									.clipShape(Capsule())

									Spacer()

									Button {
										viewModel.filterSelection = 1
									} label: {
										Text("Week")
											.foregroundStyle(viewModel.filterSelection == 1 ? Color.white : Color(uiColor: MoxieColor.grayPickerText))
											.font(.custom("Inter", size: 14))
									}
									.frame(width: geo.size.width / 4)
									.padding(4)
									.background(viewModel.filterSelection == 1 ? Color(uiColor: MoxieColor.green) : .clear)
									.clipShape(Capsule())

									Spacer()

									Button {
										viewModel.filterSelection = 2
									} label: {
										Text("Month")
											.foregroundStyle(viewModel.filterSelection == 2 ? Color.white : Color(uiColor: MoxieColor.grayPickerText))
											.font(.custom("Inter", size: 14))
									}
									.frame(width: geo.size.width / 4)
									.padding(4)
									.background(viewModel.filterSelection == 2 ? Color(uiColor: MoxieColor.green) : .clear)
									.clipShape(Capsule())

									Spacer()
								}
								.padding(.vertical, 6)
								.background(Color.white)
								.clipShape(Capsule())
								.sensoryFeedback(.selection, trigger: viewModel.filterSelection)
								.frame(maxWidth: .infinity)
								.frame(height: 40)
								.padding(.vertical, 6)

								FitnessCardView(imageSystemName: "flame.fill", title: "Calories burned", amount: viewModel.caloriesBurned, type: .calories)

								FitnessCardView(imageSystemName: "location.fill", title: "Distance travelled", amount: viewModel.distanceTraveled, type: .distance)

								FitnessCardView(imageSystemName: "heart.fill", title: "Average workout HR", amount: viewModel.averageHeartRate, noFormatting: true, type: .heartRate)

								FitnessCardView(imageSystemName: "heart.fill", title: "Resting HR", amount: viewModel.restingHeartRate, noFormatting: true, type: .heartRate)

								Spacer()
							}
							.padding(.bottom, 50)
						} else {
							ScrollView(showsIndicators: false) {
								Text("Fitness rewards and health data access")
									.font(.headline)
									.foregroundStyle(Color(uiColor: MoxieColor.primary))
									.padding([.top, .horizontal])

								Text("To participate in fitness rewards, you will need to grant access to your health data.")
									.multilineTextAlignment(.center)
									.font(.body)
									.foregroundStyle(.gray)
									.padding([.top, .horizontal])

								Text("You have full control of your data, and Moxito won't share it with any third parties. Rewards are calculated on the client side for maximum privacy.")
									.multilineTextAlignment(.center)
									.font(.body)
									.foregroundStyle(.gray)
									.padding([.top, .horizontal])

								VStack(alignment: .leading, spacing: 10) {
									Text("To manage data access, follow these steps:")
										.multilineTextAlignment(.center)
										.foregroundStyle(Color(uiColor: MoxieColor.primary))
										.font(.headline)
										.padding()

									Text("1. Tap the button below to open the Health app.")
									Text("2. In the Health app, go to 'Profile' in the top right corner.")
									Text("3. Select 'Apps' > 'Moxito' > 'Data Access & Devices'.")
									Text("4. Ensure that data sharing permissions are enabled for this app.")
								}
								.font(.subheadline)
								.lineLimit(nil)
								.frame(maxWidth: .infinity, alignment: .leading)
								.foregroundColor(.gray)
								.padding()

								Button(action: openHealthApp) {
									HStack {
										Image(systemName: "heart.fill")
											.foregroundColor(.red)
										Text("Open Health App")
											.foregroundColor(.blue)
											.underline()
									}
								}
								.padding()
								.background(Color(UIColor.secondarySystemBackground))
								.cornerRadius(10)

								Spacer()
							}
							.frame(maxWidth: .infinity)
							.padding(.vertical, 20)
							.background(Color.white)
							.clipShape(RoundedRectangle(cornerRadius: 24))
							.padding(.bottom, 50)
						}

					}
					.refreshable {
						viewModel.actions.send(.onAppear(fid: Int(mainViewModel.model.entityID) ?? 0))
						if viewModel.didAuthorizeHealthKit {
							Task {
								viewModel.fetchHealthData()
								try await mainViewModel.fetchTotalPoolRewards()
							}
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
					.sheet(isPresented: $viewModel.isScoresViewVisible, content: {
						VStack {
							List(viewModel.scores) { score in
								HStack {
									Text(score.checkInDate.formatted(.dateTime))
									Spacer()
									Text(score.score.formatted(.number.precision(.fractionLength(2))))
								}
								.foregroundStyle(Color(uiColor: MoxieColor.primary))
							}
						}
					})
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
					viewModel.actions.send(.onAppear(fid: Int(mainViewModel.model.entityID) ?? 0))
				}
			}
		}
	}

	private func openHealthApp() {
		if let url = URL(string: "x-apple-health://") {
			UIApplication.shared.open(url)
		}
	}
}

struct RewardsView_Previews: PreviewProvider {
	static var previews: some View {
		RewardsView()
			.environmentObject(MoxieViewModel())
			.environmentObject(MoxieClaimViewModel())
			.environmentObject(StepCountViewModel(didAuthorizeHealthKit: true))
	}
}
