#if os(iOS)
import ActivityKit
#endif
import WidgetKit
import SwiftUI
import MoxieLib

struct LiveActivityView: View {
	let context: ActivityViewContext<MoxieActivityAttributes>
	
	var isClaimAvailable: Bool {
		let cleanedString = context.state.claimableMoxie.replacingOccurrences(of: ",", with: "")
		
		return Double(cleanedString) ?? 0 > 0
	}

	
	var body: some View {
		VStack {
			HStack(spacing: 32) {
				VStack(alignment: .leading) {
					Text("Daily")
						.foregroundStyle(Color.white)
						.font(.custom("Inter", size: 22))
						.fontWeight(.light)
					Text(context.state.dailyMoxie)
						.foregroundStyle(Color.white)
						.font(.custom("Inter", size: 28))
						.fontWeight(.heavy)
					Text("~\(context.state.dailyUSD)")
						.foregroundStyle(Color.white)
						.font(.custom("Inter", size: 15))
						.fontWeight(.regular)
				}
				
				VStack(alignment: .leading) {
					Text("Claimable")
						.foregroundStyle(Color.white)
						.font(.custom("Inter", size: 22))
						.fontWeight(.light)
					Text(context.state.claimableMoxie)
						.foregroundStyle(Color.white)
						.font(.custom("Inter", size: 28))
						.fontWeight(.heavy)
					Text(context.state.claimableUSD)
						.foregroundStyle(Color.white)
						.font(.custom("Inter", size: 15))
						.fontWeight(.regular)
				}
			}
			.padding(.vertical)
			
			if isClaimAvailable {
				Spacer()
				
				Text("Claim")
					.font(.system(size: 14, weight: .medium, design: .default))
					.foregroundStyle(Color.white)
					.padding(4)
					.frame(maxWidth: .infinity)
					.background(Color(uiColor: MoxieColor.backgroundColor))
			}
		}
	}
}

struct MoxieWidgetSimpleLiveActivity: Widget {
	var body: some WidgetConfiguration {
		ActivityConfiguration(for: MoxieActivityAttributes.self) { context in
			LiveActivityView(context: context)
			.activityBackgroundTint(Color(uiColor: MoxieColor.primary))
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
						.fontWeight(.medium)
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
//					.font(.caption2)
			}
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
	MoxieActivityAttributes.ContentState.init(dailyMoxie: "1231", dailyUSD: "$324.23", claimableMoxie: "100", claimableUSD: "$324938", username: "tester", fid: "123", imageURL: "")
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
	MoxieActivityAttributes.ContentState.init(dailyMoxie: "1231", dailyUSD: "$324.23", claimableMoxie: "100", claimableUSD: "$324938", username: "tester", fid: "123", imageURL: "")
}
