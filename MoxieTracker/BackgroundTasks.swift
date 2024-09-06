import BackgroundTasks

extension AppDelegate {
	// Register the background task with a unique identifier
	func registerBackgroundTasks() {
		BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.christianleovido.Moxito", using: nil) { task in
			self.handleAppRefresh(task: task as! BGAppRefreshTask)
		}
	}

	// Handle the background app refresh task
	func handleAppRefresh(task: BGAppRefreshTask) {
		print("Background app refresh task started.")
		
		scheduleAppRefresh() // Reschedule the next background fetch
		
		// Perform the background fetch
		Task {
			do {
				try await MoxieViewModel.shared.fetchStats(filter: .today)
				print("Background fetch completed successfully.")
				task.setTaskCompleted(success: true) // Indicate the task was successful
			} catch {
				print("Background fetch failed with error: \(error.localizedDescription)")
				task.setTaskCompleted(success: false) // Indicate the task failed
			}
		}
		
		// Provide an expiration handler if the task is taking too long
		task.expirationHandler = {
			print("Background fetch expired.")
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
