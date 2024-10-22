import SwiftUI
import WidgetKit
import MoxieLib
import ConfettiSwiftUI
import Sentry

struct HeaderView: View {
	@EnvironmentObject var viewModel: MoxieViewModel
	@EnvironmentObject var claimViewModel: MoxieClaimViewModel

	let tab: Tab

	var body: some View {
		HStack {
			VStack(alignment: .leading) {
				Text("\(viewModel.isSearchMode ? viewModel.model.socials.first?.profileDisplayName ?? "Moxie" : "Hello, " + (viewModel.model.socials.first?.profileDisplayName ?? "Moxie"))")
					.scaledToFit()
					.font(.body)
					.font(.custom("Inter", size: 20))
					.foregroundStyle(Color.white)
					.fontWeight(.bold)
					.multilineTextAlignment(.leading)
				Text("Last update: \(viewModel.timeAgo)")
					.fontWeight(.light)
					.foregroundStyle(Color.white)
					.font(.caption)
					.font(.custom("Inter", size: 20))
					.multilineTextAlignment(.leading)
			}
			Spacer()

			Button(action: {
				withAnimation {
					claimViewModel.number = viewModel.model.moxieClaimTotals.first?.availableClaimAmount ?? 0
					claimViewModel.progress = 0
					Haptics.shared.play(.medium)

					Task {
						claimViewModel.actions.send(.initiateClaim(tab))
					}
				}
			}, label: {
				Text(viewModel.model.moxieClaimTotals.first?.availableClaimAmount == 0 ? "Claimed" : "Claim")
					.foregroundStyle(.white)
					.padding(16)
			})
			.disabled(viewModel.model.moxieClaimTotals.first?.availableClaimAmount ?? 0 == 0)
			.frame(minWidth: 102)
			.frame(height: 38)
			.font(.callout)
			.background(viewModel.model.moxieClaimTotals.first?.availableClaimAmount != 0 ? Color(uiColor: MoxieColor.green) : Color(uiColor: MoxieColor.claimButton))
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
	}
}

struct HomeView: View {
	@AppStorage("moxieData") var moxieData: Data = .init()
	@AppStorage("moxieClaimStatus") var moxieClaimStatus: Data = .init()
	@AppStorage("selectedNotificationOptionsData") var selectedNotificationOptionsData: Data = .init()
	@AppStorage("userInputNotificationsData") var userInputNotificationsString: String = ""

	@Environment(\.scenePhase) var scenePhase
	@EnvironmentObject var viewModel: MoxieViewModel
	@EnvironmentObject var claimViewModel: MoxieClaimViewModel

	var availableClaimAmountFormatted: String {
		guard let claim = viewModel.model.moxieClaimTotals.first else {
			return ""
		}
		return claim.availableClaimAmount.formatted(.number.precision(.fractionLength(0)))
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
						HeaderView(tab: .home)

						ScrollView(showsIndicators: false) {
							HStack {
								VStack(alignment: .center) {
									if viewModel.model.socials.first?.profileImage != nil {
										AsyncImage(url: URL(string: viewModel.model.socials.first!.profileImage),
															 content: { image in
											image
												.resizable()
												.aspectRatio(contentMode: .fit)
												.clipShape(Circle())
										}, placeholder: {
											ProgressView()
										})
										.frame(width: 100, height: 100)
										.padding(.top, -8)
									}

									Text("Your claimable balance is")
										.scaledToFit()
										.font(.footnote)
										.font(.custom("Inter", size: 13))
										.foregroundStyle(Color(uiColor: MoxieColor.primary))

									HStack {
										Text("\(claimViewModel.willPlayAnimationNumbers ? claimViewModel.number.formatted(.number.precision(.fractionLength(0))) : viewModel.model.moxieClaimTotals.first?.availableClaimAmount.formatted(.number.precision(.fractionLength(0))) ?? "0 $MOXIE")")
											.font(.largeTitle)
											.font(.custom("Inter", size: 20))
											.foregroundStyle(Color(uiColor: MoxieColor.primary))
											.fontWeight(.heavy)
											.onChange(of: claimViewModel.willPlayAnimationNumbers, initial: true) { _, newValue in
												if newValue {
													claimViewModel.startCountdown()
												}
											}

										Image("CoinMoxiePurple", bundle: .main)
											.resizable()
											.aspectRatio(contentMode: .fit)
											.frame(width: 20, height: 20)
									}
									Text("~$\(viewModel.dollarValueMoxie.formatted(.number.precision(.fractionLength(2))))")
										.font(.caption)
										.font(.custom("Inter", size: 12))
										.foregroundStyle(Color(uiColor: MoxieColor.primary))
								}
							}
							.frame(maxWidth: .infinity, maxHeight: 182)
							.padding(.vertical, 20)
							.background(Color.white)
							.clipShape(RoundedRectangle(cornerRadius: 24))

							HStack {
								Spacer()

								Button {
									viewModel.filterSelection = 0
								} label: {
									Text("Daily")
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
									Text("Weekly")
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
									Text("Lifetime")
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

							VStack(alignment: .leading) {
								if viewModel.inputFID == -1 {
									ContentUnavailableView {
										Label("No FID input", systemImage: "m.circe.fill")
											.foregroundStyle(Color(uiColor: MoxieColor.dark))
									} description: {
										Text("Try to search for another title.")
											.fontDesign(.rounded)
											.foregroundStyle(Color(uiColor: MoxieColor.textColor))
									}
								} else {
									VStack {
										CardView(imageSystemName: "square.grid.2x2.fill",
														 title: "Cast earnings",
														 amount: viewModel.model.castEarningsAmount,
														 price: viewModel.price,
														 info: "Earnings from casts. Likes, recasts/quoteCasts and replies all earn you $MOXIE"
										)
										.help("Just do something")

										CardView(imageSystemName: "rectangle.grid.1x2.fill",
														 title: "Frame earnings",
														 amount: viewModel.model.frameDevEarningsAmount,
														 price: viewModel.price,
														 info: "Earnings from frames that you build when you use Airstack frame validator"
										)

										CardView(imageSystemName: "circle.hexagongrid.fill",
														 title: "All earnings",
														 amount: viewModel.model.allEarningsAmount,
														 price: viewModel.price,
														 info: "All earnings from casts and frames"
										)
									}
								}
							}
						}
						Spacer()
					}
					.padding()
					.confirmationDialog("Moxie claim",
															isPresented: $claimViewModel.isClaimDialogShowing,
															titleVisibility: .visible) {
						ForEach(viewModel.wallets, id: \.self) { wallet in
							Button(wallet) {
								claimViewModel.actions.send(.selectedWallet(wallet))
							}
						}
					} message: {
						Text("Choose wallet for claiming Moxie")
					}
					.redacted(reason: viewModel.isLoading ? .placeholder : [])
					.onChange(of: scenePhase) { _, newPhase in
						if newPhase == .active {
							Task {
								await viewModel.onAppear()
							}
						} else if newPhase == .inactive {
							print("Inactive")
						} else if newPhase == .background {
							print("Background")
						}
					}
					.onChange(of: claimViewModel.willPlayAnimationNumbers, { _, newValue in
						if newValue {
							Task {
								try await viewModel.fetchStats(filter: MoxieFilter(rawValue: viewModel.filterSelection) ?? .today)
							}
						}
					})
					.onChange(of: viewModel.model, initial: true, { oldValue, newValue in
						if oldValue != newValue {
							do {
								moxieData = try CustomDecoderAndEncoder.encoder.encode(newValue)
							} catch {
								SentrySDK.capture(error: error)
							}
						}
					})
					.onChange(of: viewModel.userInputNotifications, initial: false, { oldValue, newValue in
						if oldValue != newValue {
							userInputNotificationsString = newValue.formatted(.number.precision(.fractionLength(0)))
						}
					})
					.onChange(of: viewModel.selectedNotificationOptions, initial: true, { oldValue, newValue in
						if oldValue != newValue {
							do {
								selectedNotificationOptionsData = try CustomDecoderAndEncoder.encoder.encode(viewModel.selectedNotificationOptions)
							} catch {
								SentrySDK.capture(error: error)
							}
						}
					})
					.onAppear {
						do {
							if selectedNotificationOptionsData == Data() {
								let currentSelectedNotificationOptions = try CustomDecoderAndEncoder.decoder.decode([NotificationOption].self, from: selectedNotificationOptionsData)

								viewModel.selectedNotificationOptions = currentSelectedNotificationOptions
							}

						} catch {
							SentrySDK.capture(error: error)
						}
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
											claimViewModel.actions.send(.checkClaimStatus(fid: viewModel.model.entityID, transactionId: transactionId))
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
					.alert("Wallet confirmation", isPresented: $claimViewModel.isClaimAlertShowing, actions: {
						Button {
							claimViewModel.actions.send(.claimRewards(fid: viewModel.model.entityID, wallet: claimViewModel.selectedWallet))
						} label: {
							Text("Yes")
						}

						Button {
							claimViewModel.actions.send(.initiateClaim(.home))
						} label: {
							Text("No")
						}

					}, message: {
						Text("Do you want to use \(claimViewModel.selectedWalletDisplay) to claim?")
					})
					.alert("Moxie claim success", isPresented: $claimViewModel.isClaimSuccess, actions: {
						Button {
							viewModel.confettiCounter += 1
						} label: {
							Text("Let's go!🚀")
						}
					}, message: {
						Text("\(availableClaimAmountFormatted) $MOXIE successfully claimed 🌱")
					})
//					.sensoryFeedback(.selection, trigger: claimViewModel.number)
					.sensoryFeedback(.success, trigger: claimViewModel.isClaimAlertShowing, condition: { _, newValue in
						return !newValue
					})
					.confettiCannon(counter: $viewModel.confettiCounter, num: 1,
													confettis: [.text("🍃")],
													confettiSize: 30, repetitions: 50, repetitionInterval: 0.1)
					.onAppear {
						Task {
							try await viewModel.fetchPrice()
							viewModel.timeAgoDisplay()
						}
					}
					.onAppear {
						SentrySDK.setUser(.init(userId: viewModel.model.entityID))
					}
					.overlay(alignment: .top) {
						if viewModel.error != nil {
							ErrorView(error: $viewModel.error)
						}
					}
					.refreshable {
						Task {
							try await viewModel.fetchPrice()
							try await viewModel.fetchStats(filter: MoxieFilter(rawValue: viewModel.filterSelection) ?? .today)
						}
					}
				}
			}
		}
		.tabItem {
			Image(systemName: "house.fill")
		}
	}
}

// #Preview {
//	HomeView()
//		.environment(MoxieViewModel.init(model: .placeholder))
//		.environment(\.locale, .init(components: .init(identifier: "es_ES")))
// }

#Preview {
	HomeView()
		.environment(MoxieViewModel(model: .placeholder, client: MockMoxieClient()))
}
