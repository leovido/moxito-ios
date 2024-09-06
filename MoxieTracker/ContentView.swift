import SwiftUI
import MoxieLib
import Combine

struct ContentView: View {
	@EnvironmentObject var viewModel: MoxieViewModel
	@State private var selectedTab = 0
	
	var body: some View {
		TabView(selection: $selectedTab) {
			HomeView(viewModel: viewModel)
				.sensoryFeedback(.selection, trigger: selectedTab)

			SearchListView(viewModel: .init(client: .init(), query: "", items: []))
			
			SettingsView(viewModel: viewModel)
		}
		.tint(Color(uiColor: MoxieColor.dark))
	}
}

#Preview {
	ContentView()
		.environment(MoxieViewModel(
			model: MoxieModel.placeholder,
		 client: MockMoxieClient()))
}

#Preview {
	NavigationStack {
		ScheduleNotificationView(viewModel: .init(client: MockMoxieClient()))
	}
}
