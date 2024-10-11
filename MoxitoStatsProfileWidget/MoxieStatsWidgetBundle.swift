//
//  MoxieStatsWidgetBundle.swift
//  MoxieStatsWidget
//
//  Created by Christian Ray Leovido on 09/10/2024.
//

import WidgetKit
import SwiftUI

@main
struct MoxieStatsWidgetBundle: WidgetBundle {
    var body: some Widget {
        MoxieStatsWidget()
//			if #available(iOSApplicationExtension 18.0, *) {
//				MoxieStatsWidgetControl()
//			} else {
//				// Fallback on earlier versions
//			}
        MoxieStatsWidgetLiveActivity()
    }
}
