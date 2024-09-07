import SwiftUI
import MoxieLib
import Combine

struct ContentView: View {
	@EnvironmentObject var viewModel: MoxieViewModel
	@State private var selectedTab = 0
	
	var body: some View {
		TabView(selection: $selectedTab) {
			if viewModel.isSearchMode {
				HomeView(viewModel: viewModel)
					.sensoryFeedback(.selection, trigger: selectedTab)
					.searchable(text: $viewModel.input, isPresented: $viewModel.isSearchMode)
			} else {
				HomeView(viewModel: viewModel)
					.sensoryFeedback(.selection, trigger: selectedTab)
			}

			SearchListView(viewModel: .init(client: .init(), query: "", items: []))
			
			SettingsView(viewModel: viewModel)
		}
		.tint(.white)
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
