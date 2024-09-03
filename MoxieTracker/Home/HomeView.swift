import SwiftUI
import MoxieLib

struct HomeView: View {
	@ObservedObject var viewModel: MoxieViewModel
	
	var body: some View {
		ZStack {
			Color.init(uiColor: MoxieColor.backgroundColor)
				.ignoresSafeArea(.all)
			VStack(alignment: .leading) {
				VStack {
					Text("\(viewModel.isSearchMode ? viewModel.model.socials.first?.profileDisplayName ?? "Moxie" : "Hello, " + (viewModel.model.socials.first?.profileDisplayName ?? "Moxie"))")
						.font(.largeTitle)
						.scaledToFit()
						.fontDesign(.serif)
						.foregroundStyle(Color(uiColor: MoxieColor.dark))
						.fontWeight(.bold)
					
					Picker("Filter", selection: $viewModel.filterSelection) {
							Text("Daily").tag(0)
							Text("Weekly").tag(1)
							Text("Lifetime").tag(2)
					}
					.tint(Color(uiColor: MoxieColor.dark))
					.pickerStyle(.segmented)
					.gesture(
						DragGesture()
							.onEnded { value in
								// Detect the drag direction
								if value.translation.width < 0 { // Swipe left
									if viewModel.filterSelection < viewModel.selectedNotificationOptions.count - 1 {
										viewModel.filterSelection += 1
									}
								} else if value.translation.width > 0 { // Swipe right
									if viewModel.filterSelection > 0 {
										viewModel.filterSelection -= 1
									}
								}
							}
					)
					
					TextField("Your Farcaster ID, e.g. 203666", text: $viewModel.input)
						.foregroundStyle(Color(uiColor: MoxieColor.textColor))
						.autocorrectionDisabled()
						.textFieldStyle(RoundedBorderTextFieldStyle())
						.fontDesign(.rounded)
						.padding(.vertical)
				}
				
				VStack(alignment: .leading) {
					Text("Claimable")
						.font(.title)
						.fontDesign(.serif)
						.foregroundStyle(Color(uiColor: MoxieColor.dark).blendMode(.luminosity))
						.fontWeight(.bold)
					
					Text("\(viewModel.model.moxieClaimTotals.first?.availableClaimAmount.formatted(.number.precision(.fractionLength(2))) ?? "0 $MOXIE") Ⓜ️")
						.font(.largeTitle)
						.fontDesign(.rounded)
						.foregroundStyle(Color(uiColor: MoxieColor.dark))
						.fontWeight(.heavy)
					Text("$\(viewModel.dollarValueMoxie.formatted(.number.precision(.fractionLength(2))))")
						.font(.body)
						.fontDesign(.rounded)
						.foregroundStyle(Color(uiColor: MoxieColor.dark))
						.fontWeight(.heavy)
				}
				.padding(.vertical)
				
				ScrollView {
						VStack(alignment: .leading) {
							if viewModel.inputFID == -1 {
								ContentUnavailableView {
									Label("No FID input", systemImage: "m.circle.fill")
										.foregroundStyle(Color(uiColor: MoxieColor.dark))
								} description: {
									Text("Try to search for another title.")
										.fontDesign(.rounded)
										.foregroundStyle(Color(uiColor: MoxieColor.textColor))
								}
							} else {
								VStack {
									CardView(imageSystemName: "text.bubble", 
													 title: "Cast earnings",
													 amount: viewModel.model.castEarningsAmount.formatted(.number.precision(.fractionLength(2))),
													 price: viewModel.price)
									
									CardView(imageSystemName: "laptopcomputer",
													 title: "Frame earnings",
													 amount: viewModel.model.frameDevEarningsAmount.formatted(.number.precision(.fractionLength(2))),
													 price: viewModel.price)
									
									CardView(imageSystemName: "circle.circle",
													 title: "All earnings",
													 amount: viewModel.model.allEarningsAmount.formatted(.number.precision(.fractionLength(2))),
													 price: viewModel.price)
								}
								
								Text("Last update: \(viewModel.timeAgo)")
									.italic()
									.fontDesign(.rounded)
									.fontWeight(.light)
									.foregroundStyle(Color(uiColor: MoxieColor.dark))
									.multilineTextAlignment(.center)
									.font(.caption)
							}
						}
					
				}
				
				Spacer()
			}
			.padding()
			.redacted(reason: viewModel.isLoading ? .placeholder : [])
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
	}
}

#Preview {
	HomeView(viewModel: MoxieViewModel(client: MockMoxieClient()))
}

#Preview {
	HomeView(viewModel: MoxieViewModel(isLoading: true, client: MockMoxieClient()))
}
