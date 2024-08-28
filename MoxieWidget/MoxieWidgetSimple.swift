//
//  MoxieWidgetSimple.swift
//  MoxieWidgetSimple
//
//  Created by Christian Ray Leovido on 27/08/2024.
//

import WidgetKit
import SwiftUI
import MoxieLib

enum FeatureFlag {
	static let claimButton = false
}

enum MoxieColor {
	static let textColor = UIColor(red: 0.28, green: 0.37, blue: 0.84, alpha: 1.00)
	static let backgroundColor = UIColor(red: 0.69, green: 0.53, blue: 1.00, alpha: 0.6)
	static let otherColor = UIColor(red: 0.91, green: 0.87, blue: 1.00, alpha: 1.00)
	static let dark = UIColor(red: 0.37, green: 0.16, blue: 0.79, alpha: 1.00)
}

struct Provider: AppIntentTimelineProvider {
	let client: MoxieClient = .init()
	
	func placeholder(in context: Context) -> SimpleEntry {
		SimpleEntry(date: Date(),
								dailyMoxie: 0,
								claimableMoxie: 0,
								claimedMoxie: 0,
								configuration: ConfigurationAppIntent())
	}
	
	func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
		SimpleEntry(date: Date(),
								dailyMoxie: 0,
								claimableMoxie: 0,
								claimedMoxie: 0,
								configuration: configuration)
	}
	
	func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
		let data = try! await client.fetchMoxieStats(userFID: 203666)
		
		var entries: [SimpleEntry] = [
			SimpleEntry.init(date: .now,
											 dailyMoxie: data.allEarningsAmount,
											 claimableMoxie: data.moxieClaimTotals.first!.availableClaimAmount,
											 claimedMoxie: data.moxieClaimTotals.first!.claimedAmount,
											 configuration: .init())
		]
		
		return Timeline(entries: entries, policy: .atEnd)
	}
}

struct SimpleEntry: TimelineEntry {
	let date: Date
	var dailyMoxie: Decimal
	var claimableMoxie: Decimal
	var claimedMoxie: Decimal
	let configuration: ConfigurationAppIntent
}

struct MoxieWidgetSimpleEntryView : View {
	let client = MoxieClient()
	var entry: Provider.Entry
	
	var body: some View {
		Link(destination: URL(string: "https://www.example.com/rewards")!) {
			
			VStack(alignment: .leading) {
				HStack {
					VStack(alignment: .leading) {
						Text("Daily Ⓜ️")
							.foregroundStyle(Color(uiColor: MoxieColor.textColor))
							.fontDesign(.rounded)
							.fontWeight(.black)
						
						Text(entry.dailyMoxie.formatted(.number.precision(.fractionLength(2))))
							.foregroundStyle(Color(uiColor: MoxieColor.dark))
							.fontWeight(.heavy)
							.fontDesign(.rounded)
							.padding(.bottom, 4)
						
						Text("Claimable Ⓜ️")
							.foregroundStyle(Color(uiColor: MoxieColor.textColor))
							.fontDesign(.rounded)
							.fontWeight(.black)
						
						Text(entry.claimableMoxie.formatted(.number.precision(.fractionLength(2))))
							.foregroundStyle(Color(uiColor: MoxieColor.dark))
							.fontWeight(.heavy)
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
}

//struct MoxieWidgetBigView: View {
//	let client = MoxieClient()
//	var entry: Provider.Entry
//	
//	var body: some View {
//		VStack(alignment: .center) {
////			HStack {
////				Text("@leovido - 203666")
////					.font(.custom("AvenirNext", fixedSize: 10))
////					.foregroundStyle(Color(uiColor: MoxieColor.dark))
////			}
//			
//			Spacer()
//
//			Text("DAILY Ⓜ️")
//				.foregroundStyle(Color(uiColor: MoxieColor.textColor))
//				.fontWeight(.heavy)
//				.kerning(1.0)
//				.fontDesign(.serif)
//			
//			Text("\(entry.configuration.dailyMoxie)")
//				.foregroundStyle(Color(uiColor: MoxieColor.dark))
//				.fontWeight(.medium)
//				.fontDesign(.rounded)
//				.padding(.bottom, 4)
//				.font(.custom("Avenir-Black", size: 23))
//				.textScale(.default, isEnabled: true)
//								
//			Divider()
//			
//			Text("CLAIM Ⓜ️")
//				.foregroundStyle(Color(uiColor: MoxieColor.textColor))
//				.fontWeight(.heavy)
//				.kerning(1.0)
//				.fontDesign(.serif)
//			Text("\(entry.configuration.claimableMoxie)")
//				.foregroundStyle(Color(uiColor: MoxieColor.dark))
//				.fontWeight(.heavy)
//				.fontDesign(.rounded)
//				.scaledToFit()
//				.textScale(.default)
//
//			Spacer()
//		}
//	}
//}

struct MoxieWidgetSimple: Widget {
	let kind: String = "MoxieWidgetSimple"
	
	var body: some WidgetConfiguration {
		AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
			MoxieWidgetSimpleEntryView(entry: entry)
				.containerBackground(Color(uiColor: MoxieColor.backgroundColor), for: .widget)
		}

	}
}

//struct MoxieWidgetBig: Widget {
//	let kind: String = "MoxieWidgetBig"
//	
//	var body: some WidgetConfiguration {
//		AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
//			MoxieWidgetBigView(entry: entry)
//				.containerBackground(Color(uiColor: MoxieColor.backgroundColor), for: .widget)
//		}
//	}
//}

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
							claimableMoxie: 0,
							claimedMoxie: 0,
							configuration: .smallNumber)
	SimpleEntry(date: .now,
							dailyMoxie: 0,
							claimableMoxie: 0,
							claimedMoxie: 0,
							configuration: .bigNumber)
}

//#Preview(as: .systemSmall) {
//	MoxieWidgetBig()
//} timeline: {
//	SimpleEntry(date: .now, dailyMoxie: 0,
//							claimableMoxie: 0,
//							claimedMoxie: 0,
//							configuration: .smallNumber)
//	SimpleEntry(date: .now, dailyMoxie: 0,
//							claimableMoxie: 0,
//							claimedMoxie: 0,
//							configuration: .bigNumber)
//}
