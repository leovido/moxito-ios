import SwiftUI
import MoxieLib
import Combine

struct FitnessView: View {
	@StateObject var viewModel: StepCountViewModel = .init()

	var body: some View {
		RewardsView()
		.onAppear {
			viewModel.requestHealthKitAccess()
			viewModel.fetchSteps()
		}
	}
}

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
					HomeView()
						.tag(Tab.home)
					FitnessView()
						.tag(Tab.fitness)
					AccountView()
						.tag(Tab.settings)
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
