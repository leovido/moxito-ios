import WidgetKit
import SwiftUI
import MoxieLib
import AppIntents
import Sentry
import MoxitoLib

struct Provider: AppIntentTimelineProvider {
	func placeholder(in context: Context) -> SimpleEntry {
		SimpleEntry(date: Date(),
								dailyMoxie: 0,
								dailyUSD: 0,
								claimableMoxie: 0,
								claimableUSD: 0,
								claimedMoxie: 0,
								fid: "",
								rewardsPostSplit: 0,
								rewardsPostSplitUSD: 0,
								configCheryl: .init(isEligible: false, requiredMoxie: 0, currentPriceInMoxie: "0", currentFTMoxieValue: 0, totalHoldings: 0, neededFTs: 0),
								configuration: ConfigurationAppIntent())
	}
	
	func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
		SimpleEntry(date: Date(),
								dailyMoxie: 0,
								dailyUSD: 0,
								claimableMoxie: 0,
								claimableUSD: 0,
								claimedMoxie: 0,
								fid: "",
								rewardsPostSplit: 0,
								rewardsPostSplitUSD: 0,
								configCheryl: .init(isEligible: false, requiredMoxie: 0, currentPriceInMoxie: "0", currentFTMoxieValue: 0, totalHoldings: 0, neededFTs: 0),
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
			
			let splitDetails = moxieModel.splitDetails
				.filter({ $0.entityType == "CREATOR" })
				.map({
					$0.castEarningsAmount + $0.frameDevEarningsAmount + $0.otherEarningsAmount
				})
				.reduce(0, +)
			
			let price = try await configuration.client.fetchPrice()

			let widgetConfig = try await configuration.widgetClient.checkEligibility(fid: moxieModel.entityID)
			
			let entries: [SimpleEntry] = [
				SimpleEntry(date: .now,
										dailyMoxie: moxieModel.allEarningsAmount,
										dailyUSD: price * moxieModel.allEarningsAmount,
										claimableMoxie: moxieModel.moxieClaimTotals.first?.availableClaimAmount ?? 0,
										claimableUSD: price * (moxieModel.moxieClaimTotals.first?.availableClaimAmount ?? 0),
										claimedMoxie: moxieModel.moxieClaimTotals.first?.claimedAmount ?? 0,
										fid: moxieModel.entityID,
										rewardsPostSplit: splitDetails,
										rewardsPostSplitUSD: splitDetails * price,
										configCheryl: widgetConfig,
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
	var fid: String
	var rewardsPostSplit: Decimal
	var rewardsPostSplitUSD: Decimal
	var configCheryl: CherylWidgetModel
	
	let configuration: ConfigurationAppIntent
}

struct CherylWidgetView : View {
	var entry: Provider.Entry
	
	var dollarValueDaily: String {
		return formattedDollarValue(dollarValue: entry.dailyUSD)
	}
	
	var dollarValueClaimable: String {
		return formattedDollarValue(dollarValue: entry.claimableUSD)
	}
	
	var currentDailyPostSplitUSD: String {
		return formattedDollarValue(dollarValue: entry.rewardsPostSplitUSD)
	}
	
	var body: some View {
		VStack(alignment: .leading) {
			HStack {
				Spacer()
				Image("Maxi", bundle: .main)
					.resizable()
					.aspectRatio(contentMode: .fill)
					.frame(width: 70, alignment: .center)
				Spacer()
			}
			.padding(.bottom, entry.configCheryl.isEligible ? -2 : -8)
			
			if entry.configCheryl.isEligible {
				VStack(alignment: .leading) {
					VStack {
						HStack {
							Text("DAILY")
								.kerning(1.5)
								.padding(.leading, 8)
								.font(.custom("Helvetica Neue", size: 10))
							
							Spacer()
						}
						.padding(4)
						.foregroundStyle(Color.white)
						.background(Color("BG"))
						.clipShape(Capsule())
						.padding(.bottom, -6)
						
						HStack {
							Text(entry.rewardsPostSplit.formatted(.number.precision(.fractionLength(0))))
								.foregroundStyle(Color("TextColor", bundle: .main))
								.fontWeight(.bold)
								.minimumScaleFactor(entry.rewardsPostSplit >= 1000000 ? 0.7 : 1)
								.font(.custom("Helvetica Neue", size: 18))
							
							Spacer()
							
							Text("~\(currentDailyPostSplitUSD)")
								.foregroundStyle(Color("TextDollar", bundle: .main))
								.font(.custom("Helvetica Neue", size: 11))
						}
						.padding(.horizontal)
					}
					
					VStack {
						HStack {
							Text("CLAIMABLE")
								.kerning(1.5)
								.padding(.leading, 8)
								.font(.custom("Helvetica Neue", size: 10))
							
							Spacer()
						}
						.padding(4)
						.foregroundStyle(Color.white)
						.background(Color("BG"))
						.clipShape(Capsule())
						.padding(.bottom, -6)
						
						HStack {
							Text(entry.claimableMoxie.formatted(.number.precision(.fractionLength(0))))
								.foregroundStyle(Color("TextColor", bundle: .main))
								.fontWeight(.bold)
								.font(.custom("Helvetica Neue", size: 18))
								.minimumScaleFactor(entry.rewardsPostSplit >= 1_000_000 ? 0.7 : 1)
							
							Spacer()
							
							Text("~\(dollarValueClaimable)")
								.foregroundStyle(Color("TextDollar", bundle: .main))
								.font(.custom("Helvetica Neue", size: 11))
						}
						.padding(.horizontal)
					}
					Spacer()
				}
				.padding(-8)
			} else {
				VStack {
					HStack {
						Text("@reallyryl FTs".uppercased())
							.kerning(1.5)
							.padding(.leading, 8)
							.font(.custom("Helvetica Neue", size: 10))
						
						Spacer()
					}
					.padding(4)
					.foregroundStyle(Color.white)
					.background(Color("BG"))
					.clipShape(Capsule())
					.padding(.bottom, -6)
					
					HStack {
						Text("Required")
							.foregroundStyle(Color("TextColor", bundle: .main))
							.font(.custom("Helvetica Neue", size: 13))
						
						Text("\(entry.configCheryl.neededFTs.formatted(.number.precision(.fractionLength(2))))")
							.foregroundStyle(Color("TextColor", bundle: .main))
							.fontWeight(.bold)
							.font(.custom("Helvetica Neue", size: 18))
							.minimumScaleFactor(entry.rewardsPostSplit >= 1_000_000 ? 0.7 : 1)
					}
					
					HStack {
						Text("Holdings")
							.foregroundStyle(Color("TextColor", bundle: .main))
							.font(.custom("Helvetica Neue", size: 13))
						
						Text("\(entry.configCheryl.totalHoldings.formatted(.number.precision(.fractionLength(2))))")
							.foregroundStyle(Color("TextColor", bundle: .main))
							.fontWeight(.bold)
							.font(.custom("Helvetica Neue", size: 18))
							.minimumScaleFactor(entry.rewardsPostSplit >= 1_000_000 ? 0.7 : 1)
					}
				}
			}
			Spacer()
		}
	}
}

struct CherylDarkWidgetSimple: Widget {
	let kind: String = "CherylDarkWidget"
	
	var body: some WidgetConfiguration {
		AppIntentConfiguration(kind: kind,
													 intent: ConfigurationAppIntent.self,
													 provider: Provider()
		) { entry in
			CherylWidgetView(entry: entry)
				.containerBackground(LinearGradient(
					colors: [Color("DarkBottom", bundle: .main),
									 Color("DarkTop", bundle: .main)],
					startPoint: .center,
					endPoint: .topLeading
				), for: .widget)
		}
		.configurationDisplayName("Moxito widget by @reallyryl (dark mode)")
		.description("Daily + claimable $MOXIE rewards.")
		.supportedFamilies([.systemSmall])
	}
}

#Preview(as: .systemSmall) {
	CherylDarkWidgetSimple()
	
} timeline: {
	SimpleEntry(date: .now,
							dailyMoxie: 1_000_000,
							dailyUSD: 4.32,
							claimableMoxie: 1231,
							claimableUSD: 2487,
							claimedMoxie: 0,
							fid: "123",
							rewardsPostSplit: 1234,
							rewardsPostSplitUSD: 1.23,
							configCheryl: .init(isEligible: true, requiredMoxie: 0, currentPriceInMoxie: "0", currentFTMoxieValue: 0, totalHoldings: 0, neededFTs: 0),
							configuration: .init())
	SimpleEntry(date: .now,
							dailyMoxie: 0,
							dailyUSD: 1000.33,
							claimableMoxie: 500_000,
							claimableUSD: 32.32,
							claimedMoxie: 0,
							fid: "123",
							rewardsPostSplit: 1234,
							rewardsPostSplitUSD: 1.23,
							configCheryl: .init(isEligible: false, requiredMoxie: 1300, currentPriceInMoxie: "0", currentFTMoxieValue: 0, totalHoldings: 3, neededFTs: 4.67),
							configuration: .init())
	SimpleEntry(date: .now,
							dailyMoxie: 0,
							dailyUSD: 0,
							claimableMoxie: 1_000_000,
							claimableUSD: 2487,
							claimedMoxie: 0,
							fid: "",
							rewardsPostSplit: 1_000_000,
							rewardsPostSplitUSD: 2487,
							configCheryl: .init(isEligible: true, requiredMoxie: 0, currentPriceInMoxie: "0", currentFTMoxieValue: 0, totalHoldings: 0, neededFTs: 0),
							configuration: .init())
}

