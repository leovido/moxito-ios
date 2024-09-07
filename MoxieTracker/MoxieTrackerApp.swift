import SwiftUI
import MoxieLib
import BackgroundTasks

@main
struct MoxieTrackerApp: App {
	let mainViewModel = MoxieViewModel.shared
	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	
	var body: some Scene {
		WindowGroup {
			ContentView()
				.environment(mainViewModel)
				.preferredColorScheme(.light)
				.defaultAppStorage(.group ?? .standard)
		}
	}
}
