//
//  CherylDarkWidgetLiveActivity.swift
//  CherylDarkWidget
//
//  Created by Christian Ray Leovido on 14/10/2024.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct CherylDarkWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct CherylDarkWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CherylDarkWidgetAttributes.self) { context in
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

extension CherylDarkWidgetAttributes {
    fileprivate static var preview: CherylDarkWidgetAttributes {
        CherylDarkWidgetAttributes(name: "World")
    }
}

extension CherylDarkWidgetAttributes.ContentState {
    fileprivate static var smiley: CherylDarkWidgetAttributes.ContentState {
        CherylDarkWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: CherylDarkWidgetAttributes.ContentState {
         CherylDarkWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: CherylDarkWidgetAttributes.preview) {
   CherylDarkWidgetLiveActivity()
} contentStates: {
    CherylDarkWidgetAttributes.ContentState.smiley
    CherylDarkWidgetAttributes.ContentState.starEyes
}
