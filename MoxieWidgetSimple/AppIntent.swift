//
//  AppIntent.swift
//  MoxieWidgetSimple
//
//  Created by Christian Ray Leovido on 27/08/2024.
//

import WidgetKit
import AppIntents

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
}
