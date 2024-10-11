import WidgetKit
import SwiftUI
import MoxieLib

struct Provider: TimelineProvider {
	func placeholder(in context: Context) -> SimpleEntry {
		SimpleEntry(date: .now, fcScore: .init(farRank: 10, farScore: 10, liquidityBoost: 10, powerBoost: 10, tvl: "1000", tvlBoost: 10), fansCount: 10)
	}
	
	func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
		let entry = SimpleEntry(date: .now, fcScore: .init(farRank: 10, farScore: 10, liquidityBoost: 10, powerBoost: 10, tvl: "1000", tvlBoost: 10), fansCount: 10)
		completion(entry)
	}
	
	func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
		var moxieModel: MoxieModel = .noop
		
		if let userDefaults = UserDefaults(suiteName: "group.com.christianleovido.moxito"),
			 let data = userDefaults.data(forKey: "moxieData"),
			 let decodedModel = try? CustomDecoderAndEncoder.decoder.decode(
				MoxieModel.self,
				from: data
			 ) {
			moxieModel = decodedModel
		}
		
		let entries: [SimpleEntry] = [
			SimpleEntry(date: .now,
									fcScore: .init(
										farRank: moxieModel.socials.first?.farcasterScore?.farRank ?? 0,
										farScore: moxieModel.socials.first?.farcasterScore?.farScore ?? 0,
										liquidityBoost: moxieModel.socials.first?.farcasterScore?.liquidityBoost ?? 0,
										powerBoost: moxieModel.socials.first?.farcasterScore?.powerBoost ?? 0,
										tvl: moxieModel.socials.first?.farcasterScore?.tvl ?? "",
										tvlBoost: moxieModel.socials.first?.farcasterScore?.tvlBoost ?? 0),
									fansCount: moxieModel.fansCount)
		]
		
		completion(Timeline(entries: entries, policy: .atEnd))
	}
	
	//    func relevances() async -> WidgetRelevances<Void> {
	//        // Generate a list containing the contexts this widget is relevant in.
	//    }
}

struct SimpleEntry: TimelineEntry {
	let date: Date
	let fcScore: MoxieFarcasterScore
	let fansCount: Int
}

struct MoxieStatsWidgetEntryView : View {
	var entry: Provider.Entry
	
	var body: some View {
		ZStack {
			VStack(spacing: 0) {
				HStack {
					GridItemView(title: "Fans",
											 value: entry.fansCount.description,
											 subtitle: "",
											 icon: "person.2.fill", isStat: false)
					GridItemView(title: "Score",
											 value: entry.fcScore.farScore.formatted(.number.precision(.fractionLength(2))),
											 subtitle: "",
											 icon: "chart.bar.fill",
											 isStat: false)
					GridItemView(title: "TVL",
											 value: String(format: "%.2f", entry.fcScore.tvl),
											 subtitle: "Staked",
											 icon: "lock.fill",
											 isStat: false)
				}
				HStack {
					GridItemView(title: "LP", value: entry.fcScore.liquidityBoost.formatted(.number.precision(.fractionLength(2))), subtitle: "Boost", icon: "water.waves", isStat: false)
					GridItemView(title: "TVL", value: entry.fcScore.tvlBoost.formatted(.number.precision(.fractionLength(2))), subtitle: "Boost", icon: "chart.bar.fill", isStat: false)
					GridItemView(title: "Power", value: entry.fcScore.powerBoost.formatted(.number.precision(.fractionLength(2))), subtitle: "Boost", icon: "bolt.fill", isStat: false)
				}
				
				HStack {
					GridItemView(title: "Like",
											 value: (entry.fcScore.farScore * 0.5).formatted(.number.precision(.fractionLength(0))), subtitle: "",
											 icon: "heart.fill", isStat: true)
					GridItemView(title: "Reply",
											 value: (entry.fcScore.farScore * 2).formatted(.number.precision(.fractionLength(0))), subtitle: "",
											 icon: "text.bubble.fill", isStat: true)
					GridItemView(title: "Recast", value: (entry.fcScore.farScore * 4).formatted(.number.precision(.fractionLength(0))), subtitle: "", icon: "arrowshape.turn.up.backward.fill", isStat: true)
				}
				
				VStack {
					VStack(alignment: .center, spacing: 4) {
						Spacer()
						HStack {
							Spacer()
							Text("Replyke")
								.foregroundColor(Color(uiColor: MoxieColor.primary))
								.fontDesign(.rounded)
								.font(.system(size: 18))
								.fontWeight(.black)

							
							Image(systemName: "square.stack.fill")
								.resizable()
								.aspectRatio(contentMode: .fit)
								.frame(width: 15, height: 15)
								.foregroundColor(Color(uiColor: MoxieColor.primary))
							
							Spacer()
						}
						
						HStack {
							Text((entry.fcScore.farScore * 3.5).formatted(.number.precision(.fractionLength(0))))
								.fontWeight(.heavy)
								.foregroundColor(.black)
								.minimumScaleFactor(0.4)
								.scaledToFill()
							
							Image("CoinMoxiePurple")
								.resizable()
								.aspectRatio(contentMode: .fit)
								.frame(width: 15, height: 15)
								.foregroundColor(Color(uiColor: MoxieColor.primary))
							
						}
						
							Text("")
								.font(.custom("Inter", size: 10))
								.foregroundColor(.gray)
						
					}
					.frame(height: 40)

					.padding()
					.background(RoundedRectangle(cornerRadius: 16)
						.stroke(Color.gray.opacity(0.2), lineWidth: 1))
					
					Spacer()
				}
			}
			.padding(.vertical, 4)
			
		}
	}
}

struct GridItemView: View {
	let title: String
	let value: String
	let subtitle: String
	let icon: String
	let isStat: Bool
	
	var body: some View {
		VStack {
			VStack(alignment: .leading, spacing: 4) {
				Spacer()
				HStack {
					Text(title)
						.minimumScaleFactor(0.9)
						.foregroundColor(Color(uiColor: MoxieColor.primary))
						.fontDesign(.rounded)
						.font(.system(size: 13))
						.fontWeight(.black)

					Spacer()
					
					Image(systemName: icon)
						.resizable()
						.aspectRatio(contentMode: .fit)
						.frame(width: 15, height: 15)
						.foregroundColor(Color(uiColor: MoxieColor.primary))
				}
				
				HStack {
					Text(value)
						.fontWeight(.heavy)
						.foregroundColor(.black)
						.minimumScaleFactor(0.4)
						.scaledToFill()
					
					if isStat {
						Image("CoinMoxiePurple")
							.resizable()
							.aspectRatio(contentMode: .fit)
							.frame(width: 15, height: 15)
							.foregroundColor(Color(uiColor: MoxieColor.primary))
						
					}
					
				}
				
					Text(subtitle)
						.font(.custom("Inter", size: 10))
						.foregroundColor(.gray)
				
			}
			.frame(height: 40)

			.padding()
			.background(RoundedRectangle(cornerRadius: 16)
				.stroke(Color.gray.opacity(0.2), lineWidth: 1))
			
			Spacer()
		}
	}
}

struct GridItemBigView: View {
	let farScore: Decimal
	
	var like: String {
		let d = farScore * 0.5
		
		return d.formatted(.number.precision(.fractionLength(0)))
	}
	
	var reply: String {
		let d = farScore * 1
		
		return d.formatted(.number.precision(.fractionLength(0)))
	}
	
	var recast: String {
		let d = farScore * 2
		
		return d.formatted(.number.precision(.fractionLength(0)))
	}
	
	var replyke: String {
		let d = farScore * 3.5
		
		return d.formatted(.number.precision(.fractionLength(0)))
	}
	
	var body: some View {
		VStack(alignment: .leading, spacing: 11) {
			ProfileSectionMoxieStatView(moxieStat: .init(title: "Like",
																									 value: like,
																									 icon: "heart.fill"))
			
			ProfileSectionMoxieStatView(moxieStat: .init(title: "Reply",
																									 value: reply,
																									 icon: "text.bubble.fill"))
			
			ProfileSectionMoxieStatView(moxieStat: .init(title: "Recast",
																									 value: recast,
																									 icon: "arrowshape.turn.up.backward.fill"))
			
			ProfileSectionMoxieStatView(moxieStat: .init(title: "Replyke",
																									 value: replyke,
																									 icon: "square.stack.fill"))
		}
		.padding()
		.background(RoundedRectangle(cornerRadius: 16)
			.stroke(Color.gray.opacity(0.2), lineWidth: 1))
		.background(Color.white)
	}
}


struct MoxieStatsWidget: Widget {
	let kind: String = "MoxieStatsWidget"
	
	var body: some WidgetConfiguration {
		StaticConfiguration(kind: kind, provider: Provider()) { entry in
			if #available(iOS 17.0, *) {
				MoxieStatsWidgetEntryView(entry: entry)
					.containerBackground(Color.white, for: .widget)
				
			} else {
				MoxieStatsWidgetEntryView(entry: entry)
					.containerBackground(Color.white, for: .widget)
					.padding()
					.background()
			}
		}
		.configurationDisplayName("Moxie profile stats")
		.description("Your fresh Moxie stats 🌱")
		.supportedFamilies([.systemLarge])
	}
}

#Preview(as: .systemLarge) {
	MoxieStatsWidget()
} timeline: {
	SimpleEntry(date: .now, fcScore: .init(farRank: 10, farScore: 150, liquidityBoost: 10, powerBoost: 10, tvl: "1000000", tvlBoost: 10), fansCount: 10)
	SimpleEntry(date: .now, fcScore: .init(farRank: 10, farScore: 10, liquidityBoost: 10, powerBoost: 10, tvl: "1000", tvlBoost: 10), fansCount: 10)
}
