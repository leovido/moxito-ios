import Sentry

final class ErrorHandler {
	static let shared = ErrorHandler()

	private init() {}

	func handleError(_ error: Error, additionalInfo: [String: Any]? = nil) {
		SentrySDK.capture(error: error)
	}

	func handleMessage(_ message: String) {
		let error = NSError(domain: "AppError", code: -1, userInfo: [NSLocalizedDescriptionKey: message])
		SentrySDK.capture(error: error)
	}
}
