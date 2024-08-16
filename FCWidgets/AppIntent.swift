//
//  AppIntent.swift
//  FCWidgets
//
//  Created by Christian Ray Leovido on 15/08/2024.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
	static var title: LocalizedStringResource = "Configuration"
	static var description = IntentDescription("This is an example widget.")
	
	// An example configurable parameter.
	@Parameter(title: "Favorite Emoji", default: "😃")
	var favoriteEmoji: String
}

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
struct SuperCharge: AppIntent {
	
	static var title: LocalizedStringResource = "Emoji Ranger SuperCharger"
	static var description = IntentDescription("All heroes get instant 100% health.")
	
	func perform() async throws -> some IntentResult {
		dump("here")
		return .result()
	}
}
