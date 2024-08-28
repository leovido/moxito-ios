import SwiftUI

@main
struct fc_poc_wfApp: App {
	var body: some Scene {
		WindowGroup {
			MainView()
				.onOpenURL { url in
					handleURL(url)
				}
		}
	}
	
	func handleURL(_ url: URL) {
		if url.scheme == "moxieapp" {
			if url.host == "rewards" {
				// Navigate to the rewards screen within your app
				print("Navigate to Rewards Screen")
			}
		}
	}
}
