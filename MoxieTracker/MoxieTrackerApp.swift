import SwiftUI
import MoxieLib
import BackgroundTasks

@main
struct MoxieTrackerApp: App {
	@StateObject var mainViewModel = MoxieViewModel.shared
	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	
	var body: some Scene {
		WindowGroup {
			if mainViewModel.model.entityID == "" {
				OnboardingView(viewModel: mainViewModel)
			} else {
				ContentView()
					.environment(mainViewModel)
					.preferredColorScheme(.light)
					.defaultAppStorage(.group ?? .standard)
			}
		}
	}
}
