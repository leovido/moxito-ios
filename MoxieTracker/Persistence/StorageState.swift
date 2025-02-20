import SwiftUI

final class StorageState: ObservableObject {
	@AppStorage("moxieData") var moxieData: Data = .init()
	@AppStorage("moxieClaimStatus") var moxieClaimStatus: Data = .init()
	@AppStorage("selectedNotificationOptionsData") var selectedNotificationOptionsData: Data = .init()
	@AppStorage("userInputNotificationsData") var userInputNotificationsString: String = ""
}
