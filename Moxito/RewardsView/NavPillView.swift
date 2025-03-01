import SwiftUI
import MoxieLib

struct NavPillView: View {
	@EnvironmentObject var viewModel: MoxieViewModel

	var body: some View {
		GeometryReader { geo in
			ScrollView(.horizontal) {
				HStack {
					Spacer()

					Button {
						viewModel.filterSelection = 0
					} label: {
						Text("Main")
							.foregroundStyle(viewModel.filterSelection == 0 ? Color.white : Color(uiColor: MoxieColor.grayPickerText))
							.font(.custom("Inter", size: 14))
					}
					.frame(width: geo.size.width / 4)
					.padding(4)
					.background(viewModel.filterSelection == 0 ? Color(uiColor: MoxieColor.green) : .clear)
					.clipShape(Capsule())

					Spacer()

					Button {
						viewModel.filterSelection = 1
					} label: {
						Text("Scores")
							.foregroundStyle(viewModel.filterSelection == 1 ? Color.white : Color(uiColor: MoxieColor.grayPickerText))
							.font(.custom("Inter", size: 14))
					}
					.frame(width: geo.size.width / 4)
					.padding(4)
					.background(viewModel.filterSelection == 1 ? Color(uiColor: MoxieColor.green) : .clear)
					.clipShape(Capsule())

					Spacer()

					Button {
						viewModel.filterSelection = 2
					} label: {
						Text("Calendar")
							.foregroundStyle(viewModel.filterSelection == 2 ? Color.white : Color(uiColor: MoxieColor.grayPickerText))
							.font(.custom("Inter", size: 14))
					}
					.frame(width: geo.size.width / 4)
					.padding(4)
					.background(viewModel.filterSelection == 2 ? Color(uiColor: MoxieColor.green) : .clear)
					.clipShape(Capsule())

					Spacer()
				}
				.padding(.vertical, 6)
				.background(Color.white)
				.clipShape(Capsule())
				.sensoryFeedback(.selection, trigger: viewModel.filterSelection)
	//			.sensoryFeedback(.selection, trigger: claimViewModel.number)
				.frame(maxWidth: .infinity)
				.frame(height: 40)
				.padding(.vertical, 6)}
			}
	}
}
