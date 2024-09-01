import SwiftUI
import MoxieLib

@main
struct MoxieTrackerApp: App {
	private var notificationDelegate = NotificationDelegate()

	init() {
		UNUserNotificationCenter.current().delegate = notificationDelegate
	}
	var body: some Scene {
		WindowGroup {
			ContentView(viewModel: .init(model: .noop, client: MoxieClient()))
				.preferredColorScheme(.light)
		}
	}
}

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
	func userNotificationCenter(_ center: UNUserNotificationCenter,
															willPresent notification: UNNotification,
															withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		completionHandler([.banner, .list, .sound])
	}
}
