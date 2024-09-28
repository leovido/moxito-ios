import SwiftUI
import DevCycle
import Combine

final class FeatureFlagManager: ObservableObject {
	@Published var devcycleClient: DevCycleClient?
	
	init(devcycleClient: DevCycleClient? = nil) {
		do {
			let dvcUser = try DevCycleUser.builder().build()
			dump(ProcessInfo.processInfo.environment)
			self.devcycleClient = try DevCycleClient.builder()
				.sdkKey(ProcessInfo.processInfo.environment["DEVCYCLE_API_KEY_PROD"] ?? "")
				.user(dvcUser)
				.build() { err in
					if let error = err {
						return print("Error initializing DevCycle: \(error)")
					}
				}
		} catch {
			print("Error initializing DevCycle: \(error)")
		}
	}
	
	func isSIWNAvailable() -> Bool {
		guard let devcycleClient = self.devcycleClient else {
			return false
		}
		
		// Initialize the variable value with a key and default value
		let siwnValue = devcycleClient.variableValue(
			key: "siwn",
			defaultValue: false
		)
		
		return siwnValue
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
