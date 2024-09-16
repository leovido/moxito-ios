import SwiftUI
import PrivySignIn
import Sentry

import MoxieLib
import BackgroundTasks

@main
struct MoxieTrackerApp: App {
	@StateObject var mainViewModel = MoxieViewModel.shared
	@StateObject var privyClient = PrivyClient()
	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	
	@State private var isPrivySdkReady = false
	
	var body: some Scene {
		WindowGroup {
			Group {
				if isPrivySdkReady {
					if mainViewModel.model.entityID == "" {
						OnboardingView()
					} else {
						ContentView()
					}
				} else {
					ProgressView()
				}
			}
			.environment(privyClient)
			.environment(mainViewModel)
			.preferredColorScheme(.light)
			.onAppear() {
				privyClient.privy.setAuthStateChangeCallback { state in
					if !isPrivySdkReady && state != .notReady {
								isPrivySdkReady = true
					}
				}
			}
			.defaultAppStorage(.group ?? .standard)
			.onOpenURL { url in
				print(url.absoluteString)
			}
		}
	}
}
