import SwiftUI
import MoxieLib
import Combine

struct ContentView: View {
	@EnvironmentObject var viewModel: MoxieViewModel
	@State private var selectedTab = 0
	
	var body: some View {
		TabView(selection: $selectedTab) {
			Group {
				if viewModel.isSearchMode {
					HomeView(viewModel: viewModel)
						.searchable(text: $viewModel.input, isPresented: $viewModel.isSearchMode)
						.onSubmit(of: .search) {
							viewModel.onSubmitSearch()
						}

				} else {
					HomeView(viewModel: viewModel)
				}

				SettingsView(viewModel: viewModel)
				
				AccountView(viewModel: viewModel)
			}
			.toolbar(.visible, for: .tabBar)
			.toolbarBackground(Color.yellow, for: .tabBar)
			
		}
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
