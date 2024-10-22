import SwiftUI
import MoxieLib
import Combine

struct ContentView: View {
	@EnvironmentObject var viewModel: MoxieViewModel
	@EnvironmentObject var claimViewModel: MoxieClaimViewModel
	@StateObject var stepViewModel: StepCountViewModel = .init()

	init() {
		UITabBar.appearance().isHidden = true
	}

	@State private var selectedTab: Tab = Tab.home

	var body: some View {
		ZStack(alignment: .bottom) {
			TabView(selection: $selectedTab) {
				Group {
					HomeView()
						.tag(Tab.home)
					RewardsView()
						.onAppear {
							stepViewModel.requestHealthKitAccess()
							stepViewModel.fetchSteps()
							Task {
								try await viewModel.fetchTotalPoolRewards()
							}
						}
						.tag(Tab.fitness)
					SearchListView(viewModel: .init(client: .init(), query: "", items: [], currentFID: viewModel.inputFID))
						.tag(Tab.search)
					ProfileView()
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
