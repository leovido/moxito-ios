//
//  CherylWidgetLiveActivity.swift
//  CherylWidget
//
//  Created by Christian Ray Leovido on 14/10/2024.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct CherylWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct CherylWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CherylWidgetAttributes.self) { context in
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

extension CherylWidgetAttributes {
    fileprivate static var preview: CherylWidgetAttributes {
        CherylWidgetAttributes(name: "World")
    }
}

extension CherylWidgetAttributes.ContentState {
    fileprivate static var smiley: CherylWidgetAttributes.ContentState {
        CherylWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: CherylWidgetAttributes.ContentState {
         CherylWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: CherylWidgetAttributes.preview) {
   CherylWidgetLiveActivity()
} contentStates: {
    CherylWidgetAttributes.ContentState.smiley
    CherylWidgetAttributes.ContentState.starEyes
}
