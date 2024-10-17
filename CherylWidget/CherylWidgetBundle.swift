//
//  CherylWidgetBundle.swift
//  CherylWidget
//
//  Created by Christian Ray Leovido on 14/10/2024.
//

import WidgetKit
import SwiftUI

@main
struct CherylWidgetBundle: WidgetBundle {
	var body: some Widget {
		CherylWidgetSimple()
		CherylWidgetLiveActivity()
	}
}
