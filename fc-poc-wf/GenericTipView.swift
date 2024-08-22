import SwiftUI
import TipLibs

protocol Theme {
	var primary: String { get }
	var secondary: String { get }
	var ternary: String { get }
	
	var fontMain: String { get }
}

struct HamTheme: Theme {
	let primary: String = "HamPrimary" // red
	let secondary: String = "HamSecondary" // yellow
	let ternary: String = "HamTernary" // blue
	
	let fontMain: String = "Nerko One"
	let fontTextSans: String = "Instrument Sans"
	let fontTextSerif: String = "Instrument Serif"
}

struct GenericTipView: View {
	@State private var model: TipModel?
	
	let theme: Theme

	var willRedact: RedactionReasons {
		return model != nil ? [] : .placeholder
	}
	
	var balanceFormatted: String {
		guard model != nil else {
			return "0"
		}
		let value = ((Double(model!.balance) ?? 0) * pow(10, -18)).rounded(.toNearestOrAwayFromZero)
		return value.formatted(.number.precision(.fractionLength(0)))
	}
	
	var percentageFormatted: String {
		guard let model = model else {
			return "0"
		}
		let percentage = Float(model.given) / Float(model.allowance)
		let formattedPercentage = percentage.formatted(.percent.precision(.fractionLength(2)))
		
		return formattedPercentage
	}
	
	let client: TipClient = .init()
	
	init(theme: Theme, model: TipModel? = nil) {
		self.theme = theme
		self.model = model
	}
	
	var body: some View {
		NavigationStack {
			ZStack {
				Color.white.edgesIgnoringSafeArea(.all)
				VStack {
					Text("🍖HAM🍖".uppercased())
						.font(.largeTitle)
						.foregroundStyle(Color(theme.primary))
						.fontWeight(.black)
						.font(.custom("NerkoOne-Regular", size: 10))

					ScrollView {
						VStack {
							FCard(model: model, willRedact: willRedact)

							Divider()
							
							HStack {
								VStack(alignment: .leading) {
									Text("Balance🍖")
										.font(.title)
										.fontWeight(.heavy)
										.font(.custom("NerkoOne-Regular", size: 10))
										.foregroundStyle(Color(theme.primary))
									Text("\(balanceFormatted) $HAM")
										.font(.headline)
										.foregroundStyle(Color(theme.secondary))
										.fontDesign(.rounded)
										.font(.system(size: 21))
										.fontWeight(.bold)
								}
								Spacer()
							}
							
							CircleWaveView(percent: percentageFormatted,
														 color: Color(theme.primary))
								.padding()
								.frame(width: 250)
								.redacted(reason: willRedact)
							
							VStack(alignment: .leading) {
								
								HStack {
									VStack(alignment: .leading) {
										Text("Daily✨")
											.foregroundStyle(Color(theme.primary))
											.font(.title2)
											.fontWeight(.heavy)
										
										Text("\(model?.given ?? 0)/\(model?.allowance ?? 0)")
											.fontDesign(.rounded)
											.fontWeight(.bold)
											.scaledToFill()
											.minimumScaleFactor(0.5)
											.font(.system(size: 21))
											.foregroundStyle(Color(theme.secondary))
									}
									.frame(alignment: .leading)
									.padding(.bottom, 4)
									
									Spacer()
								}
								
								VStack(alignment: .leading) {
									Text("Received✨")
										.font(.title2)
										.fontWeight(.heavy)
										.font(.custom("Avenir-Black", size: 18))
										.foregroundStyle(Color(theme.primary))

									Text("\(model?.received ?? 0)")
										.fontDesign(.rounded)
										.fontWeight(.bold)
										.font(.system(size: 21))
										.foregroundStyle(Color(theme.secondary))
									
								}
								
								Spacer()
							}
							.redacted(reason: willRedact)
							
							Spacer()
						}
						.padding()
					}
					.refreshable {
						Task {
							model = try await client.fetchFartherTips(forceRemote: true)
						}
					}
				}
				.toolbar(content: {
					ToolbarItem(placement: .topBarTrailing) {
						Menu("Menu", systemImage: "line.3.horizontal.decrease.circle") {
							Button(action: {}, label: {
								Text("$FARTHER ✨")
							})
							.tint(Color(theme.primary))
						} primaryAction: {
							// action
						}
					}
				})
				.onAppear() {
					guard model == nil else {
						return
					}
					Task {
						Thread.sleep(forTimeInterval: 1)
						model = try await client.fetchFartherTips(forceRemote: false)
					}
				}
			}
		}
	}
}

#Preview {
	GenericTipView(theme: HamTheme(), model: TipModel.placeholder)
}
