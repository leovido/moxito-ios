import UIKit
import Sentry

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
	func application(
		_ application: UIApplication,
		didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
	) -> Bool {
		UNUserNotificationCenter.current().delegate = self
		
		SentrySDK.start { options in
			options.dsn = "https://46fc916019d1fcbfdc9024e0205bfb91@o4507493157765120.ingest.de.sentry.io/4507929570443344"
			options.debug = true // Enabled debug when first installing is always helpful
			
			// Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
			// We recommend adjusting this value in production.
			options.tracesSampleRate = 1.0
			
			// Sample rate for profiling, applied on top of TracesSampleRate.
			// We recommend adjusting this value in production.
			options.profilesSampleRate = 1.0
			options.environment = "dev"
			
		}
		
		registerBackgroundTasks()
		scheduleAppRefresh()
		return true
	}
	
	func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
			// Handle the deep link here
			if url.scheme == "your-app-scheme" && url.host == "login-success" {
					// Extract any query parameters if needed
					// Notify the appropriate controller or update your state here
				NotificationCenter.default.post(name: .init("didReceiveAuth"), object: nil, userInfo: ["url": url])
			}
			return true
	}
	
	func userNotificationCenter(_ center: UNUserNotificationCenter,
															willPresent notification: UNNotification,
															withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		completionHandler([.banner, .badge, .sound])
	}
}
