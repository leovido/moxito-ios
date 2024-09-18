import WidgetKit
import SwiftUI
import MoxieLib
import AppIntents
import Sentry

enum FeatureFlag {
	static let claimButton = false
}

struct FetchDataIntent: AppIntent {
		static var title: LocalizedStringResource = "Fetch Data"
		
		// Define parameters if needed
		@Parameter(title: "API Endpoint")
		var apiEndpoint: String

		func perform() async throws -> some IntentResult {
				// Fetch data from the API
				guard let url = URL(string: apiEndpoint) else {
						throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
				}
				
				let (_, _) = try await URLSession.shared.data(from: url)
				
				// Process the fetched data here
				
				return .result(value: "Data fetched successfully!")
		}
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
	
	var dollarValueDaily: Decimal {
		do {
			let am = try Decimal(entry.dailyUSD
				.formatted(.number.precision(.fractionLength(2))),
													 format: .currency(code: "USD"))
			
			return am
		} catch {
			SentrySDK.capture(error: error)
		}
		
		return 0
	}
	
	var dollarValueClaimable: Decimal {
		do {
			let am = try Decimal(entry.claimableUSD
				.formatted(.number.precision(.fractionLength(2))),
													 format: .currency(code: "USD"))
			
			return am
		} catch {
			dump(error)
		}
		
		return 0
	}
	
	var body: some View {
			VStack(alignment: .leading) {
				HStack {
					VStack(alignment: .leading) {
						HStack {
							Text("Daily")
								.foregroundStyle(Color(uiColor: MoxieColor.textColor))
								.fontDesign(.rounded)
								.fontWeight(.black)
							
							Image("CoinMoxiePurple", bundle: .main)
								.resizable()
								.aspectRatio(contentMode: .fit)
								.frame(width: 15)
						}
						.padding(.bottom, -6)
						
						Text(entry.dailyMoxie.formatted(.number.precision(.fractionLength(2))))
							.foregroundStyle(Color(uiColor: MoxieColor.dark))
							.fontWeight(.heavy)
							.fontDesign(.rounded)
						Text("$\(dollarValueDaily.formatted())")
							.foregroundStyle(Color(uiColor: MoxieColor.dark))
							.font(.caption)
							.fontWeight(.light)
							.fontDesign(.rounded)
							.padding(.bottom, 4)

						HStack {
							Text("Claimable")
								.foregroundStyle(Color(uiColor: MoxieColor.textColor))
								.fontDesign(.rounded)
								.fontWeight(.black)
							
							Image("CoinMoxiePurple", bundle: .main)
								.resizable()
								.aspectRatio(contentMode: .fit)
								.frame(width: 15)
						}
						.padding(.bottom, -6)
						
						Text(entry.claimableMoxie.formatted(.number.precision(.fractionLength(2))))
							.foregroundStyle(Color(uiColor: MoxieColor.dark))
							.fontWeight(.heavy)
							.fontDesign(.rounded)
						Text("$\(dollarValueClaimable.formatted())")
							.foregroundStyle(Color(uiColor: MoxieColor.dark))
							.font(.caption)
							.fontWeight(.light)
							.fontDesign(.rounded)
						
						Spacer()
						
						if FeatureFlag.claimButton {
							HStack {
								Button(action: {}, label: {
									Text("Claim now")
								})
							}
						}
					}
					
					Spacer()
				}
			}
	}
}

struct MoxieWidgetSimple: Widget {
	let kind: String = "MoxieWidgetSimple"
	
	var body: some WidgetConfiguration {
		AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
			MoxieWidgetSimpleEntryView(entry: entry)
				.environment(\.colorScheme, .light)
				.containerBackground(Color("WidgetBackground"), for: .widget)
		}
		.configurationDisplayName("Moxito widget")
		.description("Shows daily $MOXIE rewards.")
		.supportedFamilies([.systemSmall])
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
	MoxieWidgetSimple()
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

