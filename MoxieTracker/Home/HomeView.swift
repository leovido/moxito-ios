import SwiftUI
import WidgetKit
import MoxieLib
import ConfettiSwiftUI

struct HomeView: View {
	@AppStorage("moxieData") var moxieData: Data = .init()
	@AppStorage("selectedNotificationOptionsData") var selectedNotificationOptionsData: Data = .init()
	@AppStorage("userInputNotificationsData") var userInputNotificationsString: String = ""
	@State private var timer: Timer?
	@State private var number: Decimal = 0

	@Environment(\.scenePhase) var scenePhase
	
	@ObservedObject var viewModel: MoxieViewModel
	
	init(viewModel: MoxieViewModel) {
		self.viewModel = viewModel

		UISegmentedControl.appearance().selectedSegmentTintColor = MoxieColor.green
			UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
		UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.gray], for: .normal)
		UISegmentedControl.appearance().backgroundColor = .white
	}
	
	var body: some View {
		NavigationStack {
			ZStack {
				Color(uiColor: MoxieColor.primary)
					.ignoresSafeArea()
				Image("wave", bundle: .main)
					.resizable()
					.ignoresSafeArea()
				VStack {
					HStack {
						VStack(alignment: .leading) {
							Text("\(viewModel.isSearchMode ? viewModel.model.socials.first?.profileDisplayName ?? "Moxie" : "Hello, " + (viewModel.model.socials.first?.profileDisplayName ?? "Moxie"))")
								.font(.body)
								.fontDesign(.rounded)
								.foregroundStyle(Color.white)
								.fontWeight(.bold)
								.multilineTextAlignment(.leading)
							Text("Last update: \(viewModel.timeAgo)")
								.fontDesign(.rounded)
								.fontWeight(.light)
								.foregroundStyle(Color.white)
								.font(.caption)
								.multilineTextAlignment(.leading)
						}
						Spacer()
						
						Button(action: {
							Haptics.shared.play(.medium)
							Task {
								try await viewModel.claimMoxie()
							}
						}, label: {
							Text("Claim")
								.foregroundStyle(.white)
								.padding(16)
						})
						.frame(height: 38)
						.font(.callout)
						.background(Color(uiColor: MoxieColor.green))
						.clipShape(Capsule())
						
						Button(action: {
							viewModel.isSearchMode.toggle()
						}, label: {
							Image(systemName: "magnifyingglass")
								.resizable()
								.aspectRatio(contentMode: .fit)
								.frame(width: 20, height: 20)
								.foregroundStyle(Color(uiColor: MoxieColor.primary))
						})
						.sensoryFeedback(.success, trigger: viewModel.isSearchMode)
						.frame(width: 38, height: 38)
						.font(.callout)
						.background(Color.white)
						.clipShape(Circle())
					}
					ScrollView(showsIndicators: false) {
						HStack {
							VStack(alignment: .center) {
								if (viewModel.model.socials.first?.profileImage != nil) {
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
								}
								
								Text("Your claimable balance is")
									.font(.footnote)
									.fontDesign(.rounded)
									.foregroundStyle(Color(uiColor: MoxieColor.primary))
								
								HStack {
									Text("\(viewModel.willPlayAnimationNumbers ? number.formatted(.number.precision(.fractionLength(2))) : viewModel.model.moxieClaimTotals.first?.availableClaimAmount.formatted(.number.precision(.fractionLength(2))) ?? "0 $MOXIE")")
										.font(.largeTitle)
										.fontDesign(.serif)
										.foregroundStyle(Color(uiColor: MoxieColor.primary))
										.fontWeight(.heavy)
										.onChange(of: viewModel.willPlayAnimationNumbers) { oldValue, newValue in
											if newValue {
												if false {
													startCountdown()
												}
											}
										}
									
									Image("CoinMoxiePurple", bundle: .main)
										.resizable()
										.aspectRatio(contentMode: .fit)
										.frame(width: 20, height: 20)
								}
								Text("~$\(viewModel.dollarValueMoxie.formatted(.number.precision(.fractionLength(2))))")
									.font(.caption)
									.fontDesign(.rounded)
									.foregroundStyle(Color(uiColor: MoxieColor.primary))
							}
						}
						.frame(maxWidth: .infinity, maxHeight: 182)
						.padding(.vertical, 20)
						.background(Color.white)
						.clipShape(RoundedRectangle(cornerRadius: 24))
						
						Picker("Filter", selection: $viewModel.filterSelection) {
							Text("Daily").tag(0)
							Text("Weekly").tag(1)
							Text("Lifetime").tag(2)
						}
						.sensoryFeedback(.selection, trigger: viewModel.filterSelection)
						.pickerStyle(.segmented)
						.padding(.vertical)
						
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
													 amount: viewModel.model.castEarningsAmount.formatted(.number.precision(.fractionLength(2))),
													 price: viewModel.price,
													 info: "Earnings from casts. Likes, recasts/quoteCasts and replies all earn you $MOXIE"
									)
									.help("Just do something")

									CardView(imageSystemName: "rectangle.grid.1x2.fill",
													 title: "Frame earnings",
													 amount: viewModel.model.frameDevEarningsAmount.formatted(.number.precision(.fractionLength(2))),
													 price: viewModel.price,
													 info: "Earnings from frames that you build when you use Airstack frame validator"
									)
									
									CardView(imageSystemName: "circle.hexagongrid.fill",
													 title: "All earnings",
													 amount: viewModel.model.allEarningsAmount.formatted(.number.precision(.fractionLength(2))),
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
				.redacted(reason: viewModel.isLoading ? .placeholder : [])
				.onChange(of: scenePhase) { oldPhase, newPhase in
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
				.onChange(of: viewModel.model, initial: false, { oldValue, newValue in
					if oldValue != newValue {
						do {
							moxieData = try CustomDecoderAndEncoder.encoder.encode(newValue)
							number = newValue.moxieClaimTotals.first?.availableClaimAmount ?? 0
						} catch {
							dump(error)
						}
					}
				})
				.onChange(of: viewModel.userInputNotifications, initial: false, { oldValue, newValue in
					if oldValue != newValue {
						userInputNotificationsString = newValue.formatted(.number.precision(.fractionLength(2)))
					}
				})
				.onChange(of: viewModel.selectedNotificationOptions, initial: false, { oldValue, newValue in
					if oldValue != newValue {
						do {
							selectedNotificationOptionsData = try CustomDecoderAndEncoder.encoder.encode(viewModel.selectedNotificationOptions)
						} catch {
							dump(error)
						}
					}
				})
				.alert("Moxie claim", isPresented: $viewModel.isClaimAlertShowing, actions: {
					Button {
						
					} label: {
						Text("Ok")
					}
					
				}, message: {
					Text("Claim will be soon available")
				})
//				.alert("Moxie claim success", isPresented: $viewModel.isClaimAlertShowing, actions: {
//					Button {
//						viewModel.confettiCounter += 1
//					} label: {
//						Text("Let's go!🚀")
//					}
//					
//				}, message: {
//					Text("You successfully claimed $MOXIE!")
//				})
				.sensoryFeedback(.success, trigger: viewModel.isClaimAlertShowing, condition: { oldValue, newValue in
					return !newValue
				})
				.confettiCannon(counter: $viewModel.confettiCounter, num:1,
												confettis: [.text("💵"), .text("💶"), .text("💷"), .text("💴")],
												confettiSize: 30, repetitions: 50, repetitionInterval: 0.1)
//				.confettiCannon(counter: $viewModel.confettiCounter,
//												num: 50, confettis: [.text("Ⓜ️"), .text("🍃"), .text("💜"), .text("🎉")], openingAngle: Angle(degrees: 0), closingAngle: Angle(degrees: 360), radius: 200)
				.onAppear() {
					Task {
						try await viewModel.fetchPrice()
						viewModel.timeAgoDisplay()
					}
				}
				.onAppear() {
					do {
						viewModel.model = try CustomDecoderAndEncoder.decoder.decode(MoxieModel.self, from: moxieData)
					} catch {
						dump(error)
					}
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
		.tabItem {
			Label("Home", systemImage: "house.fill")
		}
	}
	
	private func startCountdown() {
		let totalDuration: Decimal = 3.0 // Total countdown time in seconds
		let interval: TimeInterval = 0.01 // Fixed time interval for smooth animation
		let steps = totalDuration / Decimal(interval) // Total number of steps
		let decrementAmount: Decimal = number / steps // Amount to decrement per step
		
		// Schedule the timer
		timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
			if number > 0 {
				withAnimation(.linear(duration: interval)) {
					number -= decrementAmount // Decrement the number smoothly
				}
			} else {
				timer?.invalidate() // Stop the timer when the number reaches 0
				number = 0 // Ensure it stops exactly at 0
			}
		}
	}
}

#Preview {
	HomeView(viewModel: .init())
}

//#Preview {
//	HomeView(viewModel: MoxieViewModel(isLoading: true, client: MockMoxieClient()))
//}

struct CountdownView: View {
		@State private var number: Decimal = 1000.0 // Start value as Decimal
		@State private var timer: Timer? // Timer to handle countdown

		var body: some View {
				VStack {
						Text("\(number.formatted(.number.precision(.fractionLength(0))))")
								.font(.system(size: 50, weight: .bold, design: .rounded))
								.foregroundColor(.primary)
								.onAppear {
									if false {
										startCountdown()
									}
								}
								.onDisappear {
										timer?.invalidate() // Invalidate the timer when view disappears
								}
				}
		}

		// Function to start the countdown animation
		private func startCountdown() {
				let totalDuration: Decimal = 3.0 // Total countdown time in seconds
				let decrementInterval: Decimal = totalDuration / number // Time interval per decrement
				
				// Convert the decrement interval to Double for Timer
				timer = Timer.scheduledTimer(withTimeInterval: Double(truncating: decrementInterval as NSNumber), repeats: true) { _ in
						if number > 0 {
								withAnimation(.linear(duration: Double(truncating: decrementInterval as NSNumber))) {
										number -= 1 // Decrement the number
								}
						} else {
								timer?.invalidate() // Stop the timer when number reaches 0
						}
				}
		}
}
