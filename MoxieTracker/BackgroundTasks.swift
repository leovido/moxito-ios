import BackgroundTasks
import Sentry

extension AppDelegate {
	// Register the background task with a unique identifier
	func registerBackgroundTasks() {
		BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.christianleovido.Moxito", using: nil) { task in
			guard let task = task as? BGAppRefreshTask else {
				return
			}
			self.handleAppRefresh(task: task)
		}
	}

	// Handle the background app refresh task
	func handleAppRefresh(task: BGAppRefreshTask) {

		scheduleAppRefresh() // Reschedule the next background fetch

		// Perform the background fetch
		Task {
			do {
				try await MoxieViewModel.shared.fetchStats(filter: .today)
				MoxieViewModel.shared.checkAndNotify(newModel: MoxieViewModel.shared.model, userInput: MoxieViewModel.shared.userInputNotifications)

				task.setTaskCompleted(success: true) // Indicate the task was successful
			} catch {
				SentrySDK.capture(error: error)
				task.setTaskCompleted(success: false) // Indicate the task failed
			}
		}

		// Provide an expiration handler if the task is taking too long
		task.expirationHandler = {
			task.setTaskCompleted(success: false) // Indicate the task failed due to timeout
		}
	}

	// Schedule the next background fetch
	func scheduleAppRefresh() {
		let request = BGAppRefreshTaskRequest(identifier: "com.christianleovido.Moxito")
		request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 15)

		do {
			try BGTaskScheduler.shared.submit(request)
		} catch {
			print("Failed to schedule background task: \(error.localizedDescription)")
		}
	}
}
