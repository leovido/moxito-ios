import SwiftUI
import MoxieLib

public struct SyncingPointsView: View {
	@EnvironmentObject var viewModel: StepCountViewModel

	public init() {}

	public var body: some View {
		VStack {
			Button {
				viewModel.actions.send(.presentScoresView)
			} label: {
				Text("View scores")
					.foregroundStyle(Color.white)
					.padding(.horizontal)
			}
			.padding(8)
			.background(Color(uiColor: MoxieColor.primary))
			.clipShape(RoundedRectangle(cornerRadius: 24))
			.padding(.top, 4)
		}
	}
}
