import SwiftUI
import MoxieLib
import Combine

struct ContentView: View {
	@EnvironmentObject var viewModel: MoxieViewModel
	
	init() {
		UITabBar.appearance().isHidden = true
	}
	
	@State private var selectedTab: Tab = Tab.home
	
	var body: some View {
		ZStack(alignment: .bottom) {
			TabView(selection: $selectedTab) {
				Group {
					if viewModel.isSearchMode {
						HomeView()
							.tag(Tab.home)
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
						HomeView()
							.tag(Tab.home)
					}
					
					AccountView(viewModel: viewModel)
						.tag(Tab.profile)
				}
				.toolbar(.visible, for: .tabBar)
				.toolbarColorScheme(.light, for: .tabBar)
			}
			
			CustomBottomTabBarView(currentTab: $selectedTab)
				.ignoresSafeArea()
				.sensoryFeedback(.selection, trigger: selectedTab)
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
