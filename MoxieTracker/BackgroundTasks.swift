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

		scheduleAppRefresh()
		scheduleDataProcessing()
	}

	// Handle the first background task (App Refresh)
	func handleAppRefresh(task: BGAppRefreshTask) {
		task.expirationHandler = {
			task.setTaskCompleted(success: false)
		}

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
	}

	// Handle the second background task (Processing)
	func handleProcessingTask(task: BGProcessingTask) {
		task.expirationHandler = {
			print("❌ Processing task expired")
			task.setTaskCompleted(success: false)
		}

		scheduleDataProcessing()

		print("📊 Starting processing task at \(Date())")

		let calendar = Calendar(identifier: .gregorian)
		var utcCalendar = calendar
		utcCalendar.timeZone = TimeZone(identifier: "UTC")!

		StepCountViewModel.shared.actions.send(.calculatePoints(
			startDate: utcCalendar.startOfDay(for: Date()),
			endDate: utcCalendar.date(byAdding: .day, value: 1, to: utcCalendar.startOfDay(for: Date()))!
		))

		print("✅ Completed processing task")
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
		request.requiresNetworkConnectivity = true
		request.requiresExternalPower = false
		// Note: This timing isn't guaranteed by the system
		request.earliestBeginDate = Date(timeIntervalSinceNow: 60)

		do {
			try BGTaskScheduler.shared.submit(request)
			print("✅ Successfully scheduled next processing task")

      BGTaskScheduler.shared.getPendingTaskRequests { tasks in
				print(" Pending background tasks: \(tasks.count)")
				tasks.forEach { task in
					print("  - Task: \(task.identifier), scheduled for: \(task.earliestBeginDate?.description ?? "unknown")")
				}
		}
		} catch {
			print("❌ Failed to schedule data processing task: \(error.localizedDescription)")
		}
	}
}
