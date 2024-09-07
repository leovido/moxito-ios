import SwiftUI
import WidgetKit
import MoxieLib

struct HomeView: View {
	@AppStorage("moxieData") var moxieData: Data = .init()
	@AppStorage("selectedNotificationOptionsData") var selectedNotificationOptionsData: Data = .init()
	@AppStorage("userInputNotificationsData") var userInputNotificationsString: String = ""
	
	@Environment(\.scenePhase) var scenePhase
	
	@ObservedObject var viewModel: MoxieViewModel
	
	var body: some View {
		ZStack {
			Color(uiColor: MoxieColor.primary)
				.ignoresSafeArea()
			Image("wave", bundle: .main)
				.resizable()
				.padding(.top, 70)
				.ignoresSafeArea()
			VStack {
				HStack {
					VStack {
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
					
					Button(action: {}, label: {
						Text("Claim")
							.foregroundStyle(.white)
							.padding(16)
					})
					.font(.callout)
					.background(Color(uiColor: MoxieColor.green))
					.clipShape(Capsule())
				}
				ScrollView {
					HStack {
						VStack(alignment: .center) {
							Text("Your claimable balance is")
								.font(.footnote)
								.fontDesign(.rounded)
								.foregroundStyle(Color(uiColor: MoxieColor.primary))
							
							Text("\(viewModel.model.moxieClaimTotals.first?.availableClaimAmount.formatted(.number.precision(.fractionLength(2))) ?? "0 $MOXIE") Ⓜ️")
								.font(.largeTitle)
								.fontDesign(.serif)
								.foregroundStyle(Color(uiColor: MoxieColor.primary))
								.fontWeight(.heavy)
							Text("~$\(viewModel.dollarValueMoxie.formatted(.number.precision(.fractionLength(2))))")
								.font(.caption)
								.fontDesign(.rounded)
								.foregroundStyle(Color(uiColor: MoxieColor.primary))
						}
					}
					.padding(32)
					.background(Color.white)
					.clipShape(RoundedRectangle(cornerRadius: 24))
					.frame(maxWidth: .infinity)
					
					TextField("Your Farcaster ID, e.g. 203666", text: $viewModel.input)
						.foregroundStyle(Color(uiColor: MoxieColor.textColor))
						.autocorrectionDisabled()
						.textFieldStyle(RoundedBorderTextFieldStyle())
						.fontDesign(.rounded)
						.padding(.vertical)
					
					Picker("Filter", selection: $viewModel.filterSelection) {
						Text("Daily").tag(0)
						Text("Weekly").tag(1)
						Text("Lifetime").tag(2)
					}
					.sensoryFeedback(.selection, trigger: viewModel.filterSelection)
					.pickerStyle(.segmented)
					.padding()
					
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
						moxieData = try CustomDecoderAndEncoder.encoder.encode(viewModel.model)
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
			.onAppear() {
				Task {
					try await viewModel.fetchPrice()
					viewModel.timeAgoDisplay()
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
		.tabItem {
			Label("Home", systemImage: "house.fill")
		}
		.toolbarBackground(Color.red, for: .tabBar)
	}
}

#Preview {
	HomeView(viewModel: .init())
}

//#Preview {
//	HomeView(viewModel: MoxieViewModel(isLoading: true, client: MockMoxieClient()))
//}
