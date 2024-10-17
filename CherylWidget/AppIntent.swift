import WidgetKit
import AppIntents
@preconcurrency import MoxieLib

struct ConfigurationAppIntent: WidgetConfigurationIntent {
	let client: MoxieClient = .init()
	let widgetClient: WidgetClient = .init()

	static var title: LocalizedStringResource = "Moxie tracker"
	static var description = IntentDescription("Moxie tracker widget")
	
	// An example configurable parameter.
	@Parameter(title: "Moxie daily", default: 1000)
	var dailyMoxie: Int
	
	@Parameter(title: "Claimable", default: 1000)
	var claimableMoxie: Int
	
	@Parameter(title: "Claimed", default: 12_000)
	var claimedMoxie: Int
	
	@Parameter(title: "FID", default: 0)
	var fid: Int
	
	@Parameter(title: "Refresh", default: .daily)
	var interval: RefreshInterval
	
	enum RefreshInterval: String, AppEnum {
		case hourly, daily, weekly
		
		
		static var typeDisplayRepresentation: TypeDisplayRepresentation = "Refresh Interval"
		static var caseDisplayRepresentations: [RefreshInterval : DisplayRepresentation] = [
			.hourly: "Every Hour",
			.daily: "Every Day",
			.weekly: "Every Week",
		]
	}
}

