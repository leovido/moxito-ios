//
//  ContentView.swift
//  fc-poc-wf
//
//  Created by Christian Ray Leovido on 15/08/2024.
//

import SwiftUI
import TipLibs
//import OpenGraph

struct FartherView: View {
	@State private var ogImage: String = ""
	@State private var model: TipModel?
	
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
		let formattedPercentage = percentage.formatted(.percent.precision(.fractionLength(0)))
		
		return formattedPercentage
	}
	
	let client: TipClient = .init()
	
	init(ogImage: String = "", model: TipModel? = nil) {
		self.ogImage = ogImage
		self.model = model
	}
	
	var body: some View {
		NavigationStack {
			ZStack {
				FartherTheme.backgroundColor.edgesIgnoringSafeArea(.all)
				VStack {
					Text("✨Farther✨".uppercased())
						.font(.largeTitle)
						.foregroundStyle(FartherTheme.foregroundColor)
						.fontWeight(.black)
					ScrollView {
						VStack {
							FCard(model: model, willRedact: willRedact)

							Divider()
								.background(Color.red)
							
							HStack {
								VStack(alignment: .leading) {
									Text("Balance✨")
										.font(.title)
										.fontWeight(.heavy)
										.foregroundStyle(FartherTheme.foregroundColor)
									Text("\(balanceFormatted) $FARTHER")
										.font(.headline)
										.foregroundStyle(.white)
										.fontDesign(.rounded)
										.font(.system(size: 21))
										.fontWeight(.bold)
								}
								Spacer()
								VStack(alignment: .leading) {
									Text("Min✨")
										.font(.title)
										.fontWeight(.heavy)
										.foregroundStyle(FartherTheme.foregroundColor)

									Text("\(model?.tipMin ?? 0)")
										
										.foregroundStyle(.white)
										.fontDesign(.rounded)
										.font(.system(size: 21))
										.bold()
								}
							}
							
							CircleWaveView(percent: percentageFormatted,
														 color: Color(FartherTheme.foregroundColor))
								.padding()
								.frame(width: 250)
								.redacted(reason: willRedact)
							
							VStack(alignment: .leading) {
								
								HStack {
									VStack(alignment: .leading) {
										Text("Daily✨")
											.font(.title2)
											.fontWeight(.heavy)
										
										Text("\(model?.given ?? 0)/\(model?.allowance ?? 0)")
											.foregroundStyle(.white)
											.fontDesign(.rounded)
											.fontWeight(.bold)
											.scaledToFill()
											.minimumScaleFactor(0.5)
											.font(.system(size: 21))
										
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
									
									Text("\(model?.received ?? 0)")
										.foregroundStyle(.white)
										.fontDesign(.rounded)
										.fontWeight(.bold)
										.font(.system(size: 21))
									
								}
								
								Spacer()
							}
							.foregroundColor(FartherTheme.foregroundColor)
							.redacted(reason: willRedact)
							
							if !ogImage.isEmpty {
								AsyncImage(url: URL.init(string: ogImage)!)
							}
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
				.onAppear() {
					guard model == nil else {
						return
					}
					Task {
						Thread.sleep(forTimeInterval: 1)
						model = try await client.fetchFartherTips(forceRemote: false)
					}
		//			Task {
		//				let result = try await OpenGraph.fetch(url: URL(string: "https://toth-frame.vercel.app/toth")!)
		//
		//				self.ogImage = result.source[.image]!
		//
		//				dump(ogImage)
		//			}
				}
			}
		}
	}
}

struct MainView: View {
	var body: some View {
		NavigationStack {
			List {
				NavigationLink("$FARTHER tips") {
					FartherView()
				}
				NavigationLink("$HAM tips") {
					GenericTipView(theme: HamTheme())
				}
				.tint(Color(.red))

				NavigationLink("$DEGEN tips") {
					FartherView()
				}
			}
			.listStyle(GroupedListStyle())
			.navigationTitle("Farcaster tips")
		}
	}
}

#Preview {
	FartherView(model: TipModel.placeholder)
}

#Preview {
	MainView()
}
