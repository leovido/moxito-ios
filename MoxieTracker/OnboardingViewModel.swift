import SwiftUI
import DevCycle
import Combine
import Sentry

final class FeatureFlagManager: ObservableObject {
	@Published var devcycleClient: DevCycleClient?

	private(set) var subscriptions: Set<AnyCancellable> = []

	init(devcycleClient: DevCycleClient? = nil) {
		do {
			let dvcUser = try DevCycleUser.builder().build()
			self.devcycleClient = try DevCycleClient.builder()
				.sdkKey(ProcessInfo.processInfo.environment["DEVCYCLE_API_KEY_PROD"] ?? "")
				.user(dvcUser)
				.build { err in
					if let error = err {
						return print("Error initializing DevCycle: \(error)")
					}
				}
		} catch {
			SentrySDK.capture(error: error)
			print("Error initializing DevCycle: \(error)")
		}
	}
}

final class OnboardingViewModel: ObservableObject {
	@Published var isAlertShowing: Bool = false
	@Published var inputTextFID: String = ""

	private(set) var subscriptions: Set<AnyCancellable> = []

	init(isAlertShowing: Bool) {
		self.isAlertShowing = isAlertShowing
		self.inputTextFID = ""
	}
}
