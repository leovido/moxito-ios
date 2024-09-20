import SwiftUI
import Sentry
import MoxieLib
import BackgroundTasks

@main
struct MoxieTrackerApp: App {
	@StateObject var mainViewModel = MoxieViewModel.shared
	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	
	var body: some Scene {
		WindowGroup {
			Group {
				if mainViewModel.model.entityID == "" {
					OnboardingView()
				} else {
					ContentView()
				}
			}
			.environment(mainViewModel)
			.defaultAppStorage(.group ?? .standard)
			.onOpenURL { url in
				print(url.absoluteString)
			}
		}
	}
}
