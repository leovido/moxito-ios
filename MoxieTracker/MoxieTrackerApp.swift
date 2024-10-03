import SwiftUI
import Sentry
import MoxieLib
import Security

@main
struct MoxieTrackerApp: App {
	@StateObject var mainViewModel = MoxieViewModel.shared
	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	@AppStorage("moxieData") var moxieData: Data = .init()

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
		}
	}
}
