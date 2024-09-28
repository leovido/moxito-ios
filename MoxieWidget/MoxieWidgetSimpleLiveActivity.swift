import ActivityKit
import WidgetKit
import SwiftUI
import MoxieLib

struct LiveActivityView: View {
	let context: ActivityViewContext<MoxieActivityAttributes>
	
	var body: some View {
		VStack {
			HStack {
				VStack(alignment: .center) {
					Text("Daily")
						.foregroundStyle(Color(uiColor: MoxieColor.textColor))
						.fontDesign(.rounded)
						.fontWeight(.black)
					Text(context.state.dailyMoxie)
						.foregroundStyle(Color(uiColor: MoxieColor.dark))
						.fontWeight(.heavy)
						.fontDesign(.rounded)
					Text("~\(context.state.dailyUSD)")
						.foregroundStyle(Color(uiColor: MoxieColor.dark))
						.font(.caption)
						.fontWeight(.light)
						.fontDesign(.rounded)
				}
				
				VStack {
					Text("Claimable")
						.foregroundStyle(Color(uiColor: MoxieColor.textColor))
						.fontDesign(.rounded)
						.fontWeight(.black)
					
					Text(context.state.claimableMoxie)
						.foregroundStyle(Color(uiColor: MoxieColor.dark))
						.fontWeight(.heavy)
						.fontDesign(.rounded)
					Text(context.state.claimableUSD)
						.foregroundStyle(Color(uiColor: MoxieColor.dark))
						.font(.caption)
						.fontWeight(.light)
						.fontDesign(.rounded)
				}
			}
			.padding(.vertical)
		}
	}
}

struct MoxieWidgetSimpleLiveActivity: Widget {
	var body: some WidgetConfiguration {
		ActivityConfiguration(for: MoxieActivityAttributes.self) { context in
			LiveActivityView(context: context)
			.activityBackgroundTint(Color(uiColor: MoxieColor.backgroundColor))
			.activitySystemActionForegroundColor(Color.black)
			
		} dynamicIsland: { context in
			DynamicIsland {
				DynamicIslandExpandedRegion(.leading, priority: 1) {
					VStack(alignment: .center) {
						Text("Daily")
							.foregroundStyle(Color(uiColor: MoxieColor.textColor))
							.fontDesign(.rounded)
							.fontWeight(.black)
						Text(context.state.dailyMoxie)
							.foregroundStyle(Color(uiColor: MoxieColor.dark))
							.fontWeight(.heavy)
							.fontDesign(.rounded)
						Text("~\(context.state.dailyUSD)")
							.foregroundStyle(Color(uiColor: MoxieColor.dark))
							.font(.caption)
							.fontWeight(.light)
							.fontDesign(.rounded)
					}
						.dynamicIsland(verticalPlacement: .belowIfTooWide)
				}
//				DynamicIslandExpandedRegion(.trailing) {
//					
//				}
				DynamicIslandExpandedRegion(.bottom) {
					Text("Claimable: \(context.state.claimableMoxie)")
						.foregroundStyle(Color(uiColor: MoxieColor.primary))
						.fontWeight(.black)
						.padding(.top, 8)
					
					Text("\(context.state.claimableUSD)")
						.foregroundStyle(Color(uiColor: MoxieColor.primary))
						.fontWeight(.black)
				}
			} compactLeading: {
				HStack {
					Image(systemName: "repeat")
					Text(context.state.dailyMoxie)
				}
			} compactTrailing: {
				HStack {
					Image(systemName: "gift")
					Text(context.state.claimableMoxie)
				}
			} minimal: {
//				Text(context.state.dailyUSD)
			}
			.widgetURL(URL(string: "http://www.apple.com"))
			.keylineTint(Color.red)
		}
	}
}

extension MoxieActivityAttributes {
	fileprivate static var preview: MoxieActivityAttributes {
		MoxieActivityAttributes()
	}
}

#Preview("Notification", as: .content, using: MoxieActivityAttributes.preview) {
	MoxieWidgetSimpleLiveActivity()
} contentStates: {
	MoxieActivityAttributes.ContentState.init(dailyMoxie: "1231", dailyUSD: "$324.23", claimableMoxie: "10290412", claimableUSD: "$324938", username: "tester", fid: "123", imageURL: "")
	MoxieActivityAttributes.ContentState.init(dailyMoxie: "1231", dailyUSD: "$324.23", claimableMoxie: "10290412", claimableUSD: "$324938", username: "tester", fid: "123", imageURL: "")
}

#Preview("Dynamic island compact", as: .dynamicIsland(.compact), using: MoxieActivityAttributes.preview) {
	MoxieWidgetSimpleLiveActivity()
} contentStates: {
	MoxieActivityAttributes.ContentState.init(dailyMoxie: "1231", dailyUSD: "$324.23", claimableMoxie: "10290412", claimableUSD: "$324938", username: "tester", fid: "123", imageURL: "")
	MoxieActivityAttributes.ContentState.init(dailyMoxie: "1231", dailyUSD: "$324.23", claimableMoxie: "10290412", claimableUSD: "$324938", username: "tester", fid: "123", imageURL: "")
}

#Preview("Dynamic island expanded", as: .dynamicIsland(.expanded), using: MoxieActivityAttributes.preview) {
	MoxieWidgetSimpleLiveActivity()
} contentStates: {
	MoxieActivityAttributes.ContentState.init(dailyMoxie: "1231", dailyUSD: "$324.23", claimableMoxie: "10290412", claimableUSD: "$324938", username: "tester", fid: "123", imageURL: "")
	MoxieActivityAttributes.ContentState.init(dailyMoxie: "1231", dailyUSD: "$324.23", claimableMoxie: "10290412", claimableUSD: "$324938", username: "tester", fid: "123", imageURL: "")
}

#Preview("Dynamic island minimal", as: .dynamicIsland(.minimal), using: MoxieActivityAttributes.preview) {
	MoxieWidgetSimpleLiveActivity()
} contentStates: {
	MoxieActivityAttributes.ContentState.init(dailyMoxie: "1231", dailyUSD: "$324.23", claimableMoxie: "10290412", claimableUSD: "$324938", username: "tester", fid: "123", imageURL: "")
	MoxieActivityAttributes.ContentState.init(dailyMoxie: "1231", dailyUSD: "$324.23", claimableMoxie: "10290412", claimableUSD: "$324938", username: "tester", fid: "123", imageURL: "")
}
