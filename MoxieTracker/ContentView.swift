import SwiftUI
import MoxieLib
import Combine

struct ContentView: View {
	@EnvironmentObject var viewModel: MoxieViewModel
	
	var body: some View {
		TabView {
			Group {
				if viewModel.isSearchMode {
					HomeView(viewModel: viewModel)
						.searchable(text: $viewModel.input, isPresented: $viewModel.isSearchMode)
						.onSubmit(of: .search) {
							viewModel.onSubmitSearch()
						}
						.onAppear() {
							let searchBarAppearance = UISearchBar.appearance()
							searchBarAppearance.searchTextField.textColor = .white
							searchBarAppearance.tintColor = .white
						}
					
				} else {
					HomeView(viewModel: viewModel)
				}
				
				AccountView(viewModel: viewModel)
					.toolbarBackground(Color.red, for: .tabBar)
			}
			.toolbar(.visible, for: .tabBar)
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
