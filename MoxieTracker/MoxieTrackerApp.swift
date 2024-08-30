import SwiftUI
import MoxieLib

@main
struct MoxieTrackerApp: App {
	var body: some Scene {
		WindowGroup {
			ContentView(viewModel: .init(model: .noop, client: MoxieClient()))
		}
	}
}
