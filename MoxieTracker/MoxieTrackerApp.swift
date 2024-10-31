import SwiftUI
import Sentry
import MoxieLib
import Security

@main
struct MoxieTrackerApp: App {
	@StateObject var mainViewModel = MoxieViewModel.shared
	@StateObject var claimViewModel: MoxieClaimViewModel = .shared
	@StateObject var stepViewModel: StepCountViewModel = .init()

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
			.environment(claimViewModel)
			.environment(stepViewModel)
			.defaultAppStorage(.group ?? .standard)
		}
	}
}
