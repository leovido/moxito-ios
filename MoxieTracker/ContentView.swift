import SwiftUI
import MoxieLib
import Combine

struct ContentView: View {
	@StateObject var viewModel: MoxieViewModel
	
	var body: some View {
		TabView {
			HomeView(viewModel: viewModel)
			
			SearchListView(viewModel: .init(client: .init(), query: "", items: []))
			
			SettingsView(viewModel: viewModel)
		}
		.tint(Color(uiColor: MoxieColor.dark))
	}
}

#Preview {
	ContentView(viewModel: .init(
		model: MoxieModel.placeholder,
		client: MockMoxieClient()))
}

#Preview {
	NavigationStack {
		ScheduleNotificationView(viewModel: .init(client: MockMoxieClient()))
	}
}
