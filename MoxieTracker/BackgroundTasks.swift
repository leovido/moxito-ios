import BackgroundTasks
import Sentry

extension AppDelegate {
	// Register the background tasks
	func registerBackgroundTasks() {
		// First task registration
		BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.christianleovido.Moxito.appRefresh", using: nil) { task in
			guard let task = task as? BGAppRefreshTask else {
				return
			}
			self.handleAppRefresh(task: task)
		}

		// Second task registration
		BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.christianleovido.Moxito.processData", using: nil) { task in
			guard let task = task as? BGProcessingTask else {
				return
			}
			self.handleProcessingTask(task: task)
		}
	}

	// Handle the first background task (App Refresh)
	func handleAppRefresh(task: BGAppRefreshTask) {
		scheduleAppRefresh() // Reschedule the next background fetch

		Task {
			do {
				// Perform the background fetch logic here
				try await MoxieViewModel.shared.fetchStats(filter: .today)
				MoxieViewModel.shared.checkAndNotify(newModel: MoxieViewModel.shared.model, userInput: MoxieViewModel.shared.userInputNotifications)

				task.setTaskCompleted(success: true)
			} catch {
				SentrySDK.capture(error: error)
				task.setTaskCompleted(success: false)
			}
		}

		// Handle task expiration
		task.expirationHandler = {
			task.setTaskCompleted(success: false)
		}
	}

	// Handle the second background task (Processing)
	func handleProcessingTask(task: BGProcessingTask) {
		scheduleDataProcessing() // Reschedule the next background processing task

		Task {
			StepCountViewModel.shared.actions.send(.calculatePoints(
				startDate: Calendar.current.startOfDay(for: Date()),
				endDate: Date()
			))
		}

		// Handle task expiration
		task.expirationHandler = {
			task.setTaskCompleted(success: false)
		}
	}

	func scheduleAppRefresh() {
		let request = BGAppRefreshTaskRequest(identifier: "com.christianleovido.Moxito.appRefresh")
		request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 15) // Schedule for 15 minutes later

		do {
			try BGTaskScheduler.shared.submit(request)
		} catch {
			print("Failed to schedule app refresh task: \(error.localizedDescription)")
		}
	}

	// Schedule the second background task
	func scheduleDataProcessing() {
		let request = BGProcessingTaskRequest(identifier: "com.christianleovido.Moxito.processData")
		request.requiresNetworkConnectivity = true // Use network if needed
		request.requiresExternalPower = false     // Avoid requiring power for flexibility
		request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 60 * 1)

		do {
			try BGTaskScheduler.shared.submit(request)
		} catch {
			print("Failed to schedule data processing task: \(error.localizedDescription)")
		}
	}
}
