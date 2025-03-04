import UserNotifications
import Sentry

protocol NotificationProvider {
	func requestAuthorization() async throws
	func scheduleNotification(for milestone: Int, currentSteps: Int) async throws
	func cancelAllNotifications() async
	func getPendingNotifications() async -> [UNNotificationRequest]
}

final class NotificationService: NotificationProvider {
	private let notificationCenter = UNUserNotificationCenter.current()

	func requestAuthorization() async throws {
		do {
			let granted = try await notificationCenter.requestAuthorization(
				options: [.alert, .sound, .badge]
			)
			guard granted else {
				throw NotificationError.authorizationDenied
			}
		} catch {
			SentrySDK.capture(error: error)
			throw NotificationError.authorizationFailed(error)
		}
	}

	func scheduleNotification(for milestone: Int, currentSteps: Int) async throws {
		let content = UNMutableNotificationContent()
		content.title = "Step Goal Update"
		content.body = "You're \(milestone - currentSteps) steps away from your next milestone!"
		content.sound = .default

		let trigger = UNTimeIntervalNotificationTrigger(
			timeInterval: 3600,
			repeats: false
		)

		let request = UNNotificationRequest(
			identifier: UUID().uuidString,
			content: content,
			trigger: trigger
		)

		do {
			try await notificationCenter.add(request)
		} catch {
			SentrySDK.capture(error: error)
			throw NotificationError.schedulingFailed(error)
		}
	}

	func cancelAllNotifications() {
		notificationCenter.removeAllPendingNotificationRequests()
	}

	func getPendingNotifications() async -> [UNNotificationRequest] {
		return await notificationCenter.pendingNotificationRequests()
	}
}

enum NotificationError: LocalizedError {
	case authorizationDenied
	case authorizationFailed(Error)
	case schedulingFailed(Error)

	var errorDescription: String? {
		switch self {
		case .authorizationDenied:
			return "Notification permission was denied"
		case .authorizationFailed(let error):
			return "Failed to request notification permission: \(error.localizedDescription)"
		case .schedulingFailed(let error):
			return "Failed to schedule notification: \(error.localizedDescription)"
		}
	}
}
