import Foundation
import WidgetKit
import TipLibs

struct Provider: AppIntentTimelineProvider {
	let client: TipClient = .init()
	
	func placeholder(in context: Context) -> SimpleEntry {
		SimpleEntry(date: Date(),
								model: TipModel.placeholder,
								configuration: ConfigurationAppIntent())
	}
	
	func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
		SimpleEntry(date: Date(),
								model: TipModel.placeholder,
								configuration: configuration)
	}
	
	func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
		var entries: [SimpleEntry] = []
		
		let result = try! await client.fetchFartherTips(forceRemote: false)
		
		// Generate a timeline consisting of five entries an hour apart, starting from the current date.
		let currentDate = Date()
		for hourOffset in 0 ..< 5 {
			let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
			let entry = SimpleEntry(date: Date(), model: result, configuration: configuration)
			entries.append(entry)
		}
		
		return Timeline(entries: entries, policy: .atEnd)
	}
}

struct SimpleEntry: TimelineEntry {
	var date: Date
	
	let model: TipModel
	let configuration: ConfigurationAppIntent
}
