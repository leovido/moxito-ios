import SwiftUI
import MoxieLib
import BackgroundTasks

@main
struct MoxieTrackerApp: App {
	let mainViewModel = MoxieViewModel()
	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	
	private var notificationDelegate = NotificationDelegate()
	
	init() {
		UNUserNotificationCenter.current().delegate = notificationDelegate
		registerBackgroundTasks()
	}
	
	var body: some Scene {
		WindowGroup {
			ContentView()
				.environment(mainViewModel)
				.preferredColorScheme(.light)
		}
	}
	
	// Register the background task with a unique identifier
	private func registerBackgroundTasks() {
		BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.christianleovido.moxito", using: nil) { task in
			self.handleAppRefresh(task: task as! BGAppRefreshTask)
		}
	}
	
	// Handle the background app refresh task
	private func handleAppRefresh(task: BGAppRefreshTask) {
		scheduleAppRefresh() // Reschedule the next background fetch
		
		// Perform the background fetch
		Task {
			do {
				try await mainViewModel.fetchStats(filter: .today)
				task.setTaskCompleted(success: true) // Indicate the task was successful
			} catch {
				task.setTaskCompleted(success: false) // Indicate the task failed
			}
		}
		
		// Provide an expiration handler if the task is taking too long
		task.expirationHandler = {
			task.setTaskCompleted(success: false) // Indicate the task failed due to timeout
		}
	}
	
	// Schedule the next background fetch
	private func scheduleAppRefresh() {
		let request = BGAppRefreshTaskRequest(identifier: "com.christianleovido.moxito")
		request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 30)
		
		do {
			try BGTaskScheduler.shared.submit(request)
		} catch {
			print("Failed to schedule background task: \(error.localizedDescription)")
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
