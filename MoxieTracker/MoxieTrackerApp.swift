import SwiftUI
import Sentry
import MoxieLib
import BackgroundTasks
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
					OnboardingView()
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
		let signer = queryItems.first(where: { $0.name == "signerUUID" })?.value
		let fid = queryItems.first(where: { $0.name == "fid" })?.value
		
		if let signer = signer, let fid = fid {
			saveToKeychain(token: signer, for: fid, service: "com.christianleovido.Moxito")
			
			mainViewModel.input = fid
			mainViewModel.inputFID = Int(fid) ?? 0
		}
	}
}
