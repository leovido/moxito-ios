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
			.onAppear() {
				do {
					mainViewModel.model = try CustomDecoderAndEncoder.decoder.decode(MoxieModel.self, from: moxieData)
					
					mainViewModel.input = mainViewModel.model.entityID
					mainViewModel.inputFID = Int(mainViewModel.model.entityID) ?? 0
					_ = retrieveFromKeychain(account: mainViewModel.model.entityID)
				} catch {
					SentrySDK.capture(error: error)
				}
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
			mainViewModel.input = fid
			mainViewModel.inputFID = Int(fid) ?? 0
			saveToKeychain(token: signer, for: fid)
		}
	}
	
	func saveToKeychain(token: String, for account: String) {
		let tokenData = token.data(using: .utf8)!
		let query = [
			kSecClass: kSecClassGenericPassword,
			kSecAttrAccount: account,
			kSecValueData: tokenData
		] as CFDictionary
		SecItemAdd(query, nil)
	}
	
	func retrieveFromKeychain(account: String) -> String? {
		let query = [
			kSecClass: kSecClassGenericPassword,
			kSecAttrAccount: account,
			kSecReturnData: true,
			kSecMatchLimit: kSecMatchLimitOne
		] as CFDictionary
		
		var dataTypeRef: AnyObject?
		let status = SecItemCopyMatching(query, &dataTypeRef)
		
		if status == errSecSuccess, let retrievedData = dataTypeRef as? Data {
			return String(data: retrievedData, encoding: .utf8)
		}
		return nil
	}
	
}
