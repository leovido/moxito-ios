import SwiftUI
import MoxieLib
import BackgroundTasks

@main
struct MoxieTrackerApp: App {
	@StateObject var mainViewModel = MoxieViewModel.shared
	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	
	init() {
		UITabBar.setAppearance() // Apply the custom tab bar appearance
	}
	
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
			.preferredColorScheme(.light)
			.defaultAppStorage(.group ?? .standard)
			
		}
	}
}

extension UITabBar {
	static func setAppearance() {
		let appearance = UITabBarAppearance()
		appearance.configureWithOpaqueBackground() // Choose the desired configuration
		
		appearance.backgroundColor = UIColor.primary // Set the background color
		
		UITabBar.appearance().standardAppearance = appearance
		UITabBar.appearance().scrollEdgeAppearance = appearance
		
		UITabBar.appearance().tintColor = UIColor.systemGreen // Change the active tab icon and text color
		UITabBar.appearance().unselectedItemTintColor = UIColor.systemGray // Change the inactive tab icon and text color
	}
}
