//
//  MoxieWidgetSimpleLiveActivity.swift
//  MoxieWidgetSimple
//
//  Created by Christian Ray Leovido on 27/08/2024.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct MoxieWidgetSimpleAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct MoxieWidgetSimpleLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MoxieWidgetSimpleAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension MoxieWidgetSimpleAttributes {
    fileprivate static var preview: MoxieWidgetSimpleAttributes {
        MoxieWidgetSimpleAttributes(name: "World")
    }
}

extension MoxieWidgetSimpleAttributes.ContentState {
    fileprivate static var smiley: MoxieWidgetSimpleAttributes.ContentState {
        MoxieWidgetSimpleAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: MoxieWidgetSimpleAttributes.ContentState {
         MoxieWidgetSimpleAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: MoxieWidgetSimpleAttributes.preview) {
   MoxieWidgetSimpleLiveActivity()
} contentStates: {
    MoxieWidgetSimpleAttributes.ContentState.smiley
    MoxieWidgetSimpleAttributes.ContentState.starEyes
}
