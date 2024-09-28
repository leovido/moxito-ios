import SwiftUI
import Sentry
import MoxieLib
import Security

@main
struct MoxieTrackerApp: App {
	@StateObject var mainViewModel = MoxieViewModel.shared
	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	@AppStorage("moxieData") var moxieData: Data = .init()
	
	var body: some Scene {
		WindowGroup {
			Group {
				if mainViewModel.model.entityID == "" {
					OnboardingView(featureFlagManager: .init())
				} else {
					ContentView()
				}
			}
			.environment(mainViewModel)
			.defaultAppStorage(.group ?? .standard)
			.onOpenURL { url in
				handleDeepLink(url: url)
			}
		}
	}
	
	func handleDeepLink(url: URL) {
		guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
					components.scheme == "moxito",
					components.host == "auth",
					let queryItems = components.queryItems else {
			return
		}
		let signer64 = queryItems.first(where: { $0.name == "id" })?.value
		let fid64 = queryItems.first(where: { $0.name == "fid" })?.value
		
		if let signer = signer64, let fid = fid64 {
			if let decodedSigner = Data(base64Encoded: signer),
				 let decodedSignerString = String(data: decodedSigner, encoding: .utf8),
				 let decodedFID = Data(base64Encoded: fid),
				 let decodedFIDString = String(data: decodedFID, encoding: .utf8) {
				saveToKeychain(token: signer, for: fid, service: "com.christianleovido.Moxito")
				
				mainViewModel.input = decodedFIDString
				mainViewModel.inputFID = Int(decodedFIDString) ?? 0
			} else {
				print("Failed to decode Base64 data")
			}
			
		}
	}
}
