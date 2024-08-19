//
//  FartherWidgetLiveActivity.swift
//  FartherWidget
//
//  Created by Christian Leovido on 19/08/2024.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct FartherWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct FartherWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FartherWidgetAttributes.self) { context in
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

extension FartherWidgetAttributes {
    fileprivate static var preview: FartherWidgetAttributes {
        FartherWidgetAttributes(name: "World")
    }
}

extension FartherWidgetAttributes.ContentState {
    fileprivate static var smiley: FartherWidgetAttributes.ContentState {
        FartherWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: FartherWidgetAttributes.ContentState {
         FartherWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: FartherWidgetAttributes.preview) {
   FartherWidgetLiveActivity()
} contentStates: {
    FartherWidgetAttributes.ContentState.smiley
    FartherWidgetAttributes.ContentState.starEyes
}
