//
//  MoxieStatsWidgetLiveActivity.swift
//  MoxieStatsWidget
//
//  Created by Christian Ray Leovido on 09/10/2024.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct MoxieStatsWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct MoxieStatsWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MoxieStatsWidgetAttributes.self) { context in
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

extension MoxieStatsWidgetAttributes {
    fileprivate static var preview: MoxieStatsWidgetAttributes {
        MoxieStatsWidgetAttributes(name: "World")
    }
}

extension MoxieStatsWidgetAttributes.ContentState {
    fileprivate static var smiley: MoxieStatsWidgetAttributes.ContentState {
        MoxieStatsWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: MoxieStatsWidgetAttributes.ContentState {
         MoxieStatsWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: MoxieStatsWidgetAttributes.preview) {
   MoxieStatsWidgetLiveActivity()
} contentStates: {
    MoxieStatsWidgetAttributes.ContentState.smiley
    MoxieStatsWidgetAttributes.ContentState.starEyes
}
