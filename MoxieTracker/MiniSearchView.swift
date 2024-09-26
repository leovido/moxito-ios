import SwiftUI
import WidgetKit
import MoxieLib
import ConfettiSwiftUI
import Sentry

struct MiniSearchView: View {
	@StateObject var viewModel: MoxieViewModel
	
	var body: some View {
		GeometryReader { geo in
			ZStack {
				Color(uiColor: MoxieColor.primary)
					.ignoresSafeArea()
				Image("wave", bundle: .main)
					.resizable()
					.ignoresSafeArea()
				VStack {
					HStack {
						VStack(alignment: .leading) {
							Text("\(viewModel.model.socials.first?.profileDisplayName ?? "Moxie")")
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
						
					}
					.padding(.bottom, 20)

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
									.padding(.top, -8)
								}
								
								Text("Their claimable balance is")
									.font(.footnote)
									.font(.custom("Inter", size: 13))
									.foregroundStyle(Color(uiColor: MoxieColor.primary))
								
								HStack {
									Text("\(viewModel.model.moxieClaimTotals.first?.availableClaimAmount.formatted(.number.precision(.fractionLength(0))) ?? "0 $MOXIE")")
										.font(.largeTitle)
										.font(.custom("Inter", size: 20))
										.foregroundStyle(Color(uiColor: MoxieColor.primary))
										.fontWeight(.heavy)
									
									Image("CoinMoxiePurple", bundle: .main)
										.resizable()
										.aspectRatio(contentMode: .fit)
										.frame(width: 20, height: 20)
								}
								Text("~$\(viewModel.dollarValueMoxie.formatted(.number.precision(.fractionLength(0))))")
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
		}
	}
}

#Preview {
	MiniSearchView(viewModel: .init())
}
