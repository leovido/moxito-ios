import WidgetKit
import AppIntents
import MoxieLib

//extension MoxieModel: AppEntity {
//	public var id: ObjectIdentifier {
//		return UUID().uuidString
//	}
//	
//	public static var defaultQuery: MoxieModelQuery = MoxieModelQuery()
//	
//	public static var typeDisplayRepresentation: TypeDisplayRepresentation = .init(name: "Moxie Model")
//	
//	public var displayRepresentation: DisplayRepresentation {
//		DisplayRepresentation(title: "Total moxie")
//}
//	
//}

//public struct MoxieModelQuery: EntityQuery {
//	public func entities(for identifiers: [MoxieModel.ID]) async throws -> [MoxieModel] {
//		return [.placeholder]
//		
//	}
//	
//	public func suggestedEntities() async throws -> [MoxieModel] {
//		return [.placeholder]
//	}
//	
//	public func defaultResult() async -> MoxieModel? {
//		try? await suggestedEntities().first
//	}
//	
//	public init() {}
//}

struct ConfigurationAppIntent: WidgetConfigurationIntent {
	static var title: LocalizedStringResource = "Moxie tracker"
	static var description = IntentDescription("Moxie tracker widget")
	
	// An example configurable parameter.
	@Parameter(title: "Moxie daily", default: 1000)
	var dailyMoxie: Int
	
	@Parameter(title: "Claimable", default: 1000)
	var claimableMoxie: Int
	
	@Parameter(title: "Claimed", default: 12_000)
	var claimedMoxie: Int
	
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

