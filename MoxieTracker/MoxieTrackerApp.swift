import SwiftUI
import Sentry

import MoxieLib
import BackgroundTasks

@main
struct MoxieTrackerApp: App {
    init() {
        SentrySDK.start { options in
            options.dsn = "https://46fc916019d1fcbfdc9024e0205bfb91@o4507493157765120.ingest.de.sentry.io/4507929570443344"
            options.debug = true // Enabled debug when first installing is always helpful
            options.enableTracing = true 

            // Uncomment the following lines to add more data to your events
            // options.attachScreenshot = true // This adds a screenshot to the error events
            // options.attachViewHierarchy = true // This adds the view hierarchy to the error events
        }
        // Remove the next line after confirming that your Sentry integration is working.
        SentrySDK.capture(message: "This app uses Sentry! :)")
    }
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
			.preferredColorScheme(.light)
			.defaultAppStorage(.group ?? .standard)
			
		}
	}
}
