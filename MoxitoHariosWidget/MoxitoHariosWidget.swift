import WidgetKit
import SwiftUI
import MoxieLib
import AppIntents

enum FeatureFlag {
	static let claimButton = false
}

struct Provider: AppIntentTimelineProvider {
	func placeholder(in context: Context) -> SimpleEntry {
		SimpleEntry(date: Date(),
								dailyMoxie: 0,
								dailyUSD: 0,
								claimableMoxie: 0,
								claimableUSD: 0,
								claimedMoxie: 0,
								configuration: ConfigurationAppIntent())
	}
	
	func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
		SimpleEntry(date: Date(),
								dailyMoxie: 0,
								dailyUSD: 0,
								claimableMoxie: 0,
								claimableUSD: 0,
								claimedMoxie: 0,
								configuration: configuration)
	}
	
	func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
		do {
			var moxieModel: MoxieModel = .noop

			if let userDefaults = UserDefaults(suiteName: "group.com.christianleovido.moxito"),
				 let data = userDefaults.data(forKey: "moxieData"),
				 let decodedModel = try? CustomDecoderAndEncoder.decoder.decode(
					MoxieModel.self,
					from: data
				 ) {
				moxieModel = decodedModel
			}
			
			let price = try await configuration.client.fetchPrice()
			
			let entries: [SimpleEntry] = [
				SimpleEntry.init(date: .now,
												 dailyMoxie: moxieModel.allEarningsAmount,
												 dailyUSD: price * moxieModel.allEarningsAmount,
												 claimableMoxie: moxieModel.moxieClaimTotals.first!.availableClaimAmount,
												 claimableUSD: price * moxieModel.moxieClaimTotals.first!.availableClaimAmount,
												 claimedMoxie: moxieModel.moxieClaimTotals.first!.claimedAmount,
												 configuration: .init())
			]
			
			return Timeline(entries: entries, policy: .atEnd)
		} catch {
			return Timeline(entries: [], policy: .atEnd)
		}
	}
}

struct SimpleEntry: TimelineEntry {
	let date: Date
	var dailyMoxie: Decimal
	var dailyUSD: Decimal
	var claimableMoxie: Decimal
	var claimableUSD: Decimal
	var claimedMoxie: Decimal
	
	let configuration: ConfigurationAppIntent
}

struct MoxieWidgetSimpleEntryView : View {
	var entry: Provider.Entry
	
	var body: some View {
		ZStack {
			Image("MoxitoBG", bundle: .main)
			VStack {
				MiniCard(title: "Daily earnings:", moxieValue: entry.dailyMoxie, moxieUSD: entry.dailyUSD, imgSystem: "square.grid.2x2.fill")
					.padding(.top)
				MiniCard(title: "Claimable:", moxieValue: entry.claimedMoxie, moxieUSD: entry.claimableUSD, imgSystem: "square.grid.3x3.fill")
			}
		}
			
	}
}

struct MiniCard: View {
	let title: String
	let moxieValue: Decimal
	let moxieUSD: Decimal
	let imgSystem: String
	
	init(title: String, moxieValue: Decimal, moxieUSD: Decimal, imgSystem: String) {
		self.title = title
		self.moxieValue = moxieValue
		self.moxieUSD = moxieUSD
		self.imgSystem = imgSystem
	}
	
	var body: some View {
		HStack {
			VStack {
				Image(systemName: imgSystem)
					.resizable()
					.renderingMode(.template) // Use .template to apply the foreground color
					.aspectRatio(contentMode: .fit)
					.frame(width: 10, height: 10)
					.foregroundColor(.white) // Set the SF Symbol color to white
					
			}
			.frame(width: 22, height: 22)
			.background(
				RoundedRectangle(cornerRadius: 3)
					.fill(Color(uiColor: MoxieColor.green))
			)
			.padding(.leading, 8)
			
			VStack(alignment: .leading, spacing: 0) {
				Text(title)
					.font(.system(size: 8))
					.fontWeight(.bold)
					.fontDesign(.rounded)
					.foregroundStyle(Color.white)
				
				HStack(spacing: 1) {
					Text(moxieValue.formatted(.number.precision(.fractionLength(2))))
						.font(.system(size: 15))
						.textScale(.secondary)
						.fontDesign(.rounded)
						.foregroundStyle(Color.white)
						.fontWeight(.bold)
					
					Image("CoinMoxie", bundle: .main)
						.resizable()
						.aspectRatio(contentMode: .fit)
						.frame(height: 20)
				}
				
				Text("~$\(moxieUSD.formatted(.number.precision(.fractionLength(2))))")
					.font(.system(size: 7))
					.fontDesign(.rounded)
					.foregroundStyle(Color.white)
					.fontWeight(.light)
			}
			.padding(.all, 0)
			
			Spacer()
		}
		.frame(width: 140, height: 48)
		.background(Color(uiColor: MoxieColor.primary))
		.clipShape(RoundedRectangle(cornerSize: CGSize(width: 8, height: 8)))
	}
}

struct MoxitoHariosWidget: Widget {
	let kind: String = "MoxitoHariosWidget"
	
	var body: some WidgetConfiguration {
		AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
			MoxieWidgetSimpleEntryView(entry: entry)
				.environment(\.colorScheme, .light)
				.containerBackground(Color(uiColor: MoxieColor.primary), for: .widget)
		}
		.configurationDisplayName("Moxito widget by @harios")
		.description("Shows daily $MOXIE rewards.")
	}
}

extension ConfigurationAppIntent {
	fileprivate static var smallNumber: ConfigurationAppIntent {
		let intent = ConfigurationAppIntent()
		intent.dailyMoxie = 10
		intent.claimableMoxie = 100
		intent.claimedMoxie = 500
		return intent
	}
	
	fileprivate static var bigNumber: ConfigurationAppIntent {
		let intent = ConfigurationAppIntent()
		intent.dailyMoxie = 1_000_000
		intent.claimableMoxie = 10_000_000
		intent.claimedMoxie = 20_000_000
		return intent
	}
}

#Preview(as: .systemSmall) {
	MoxitoHariosWidget()
} timeline: {
	SimpleEntry(date: .now,
							dailyMoxie: 0,
							dailyUSD: 4.32,
							claimableMoxie: 0,
							claimableUSD: 32.32,
							claimedMoxie: 0,
							configuration: .smallNumber)
	SimpleEntry(date: .now,
							dailyMoxie: 0,
							dailyUSD: 1000.33,
							claimableMoxie: 0,
							claimableUSD: 32.32,
							claimedMoxie: 0,
							configuration: .bigNumber)
}

