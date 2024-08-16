//
//  FCWidgetsLiveActivity.swift
//  FCWidgets
//
//  Created by Christian Ray Leovido on 15/08/2024.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct FCWidgetsAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct FCWidgetsLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FCWidgetsAttributes.self) { context in
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

extension FCWidgetsAttributes {
    fileprivate static var preview: FCWidgetsAttributes {
        FCWidgetsAttributes(name: "World")
    }
}

extension FCWidgetsAttributes.ContentState {
    fileprivate static var smiley: FCWidgetsAttributes.ContentState {
        FCWidgetsAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: FCWidgetsAttributes.ContentState {
         FCWidgetsAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: FCWidgetsAttributes.preview) {
   FCWidgetsLiveActivity()
} contentStates: {
    FCWidgetsAttributes.ContentState.smiley
    FCWidgetsAttributes.ContentState.starEyes
}
