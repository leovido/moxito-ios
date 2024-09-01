import SwiftUI
import MoxieLib

struct SettingsView: View {
	@ObservedObject var viewModel: MoxieViewModel
	
	var body: some View {
		NavigationStack {
			ZStack {
				VStack {
					ProfileCardView(model: viewModel.model)
						.padding(.vertical)
					
					List {
						Section {
							NavigationLink("Schedule notifications") {
								ScheduleNotificationView(viewModel: viewModel)
							}
						} header: {
							Text("Notifications")
						} footer: {
							Text("Receive push notifications at scheduled intervals for daily and claimable $MOXIE.")
						}
					}
					.listStyle(GroupedListStyle())
					
					Spacer()
				}
				.navigationTitle("Settings")
			}
		}
		.tabItem {
			Label("Settings", systemImage: "gearshape")
		}
	}
}

#Preview {
	SettingsView(viewModel: .init(client: MockMoxieClient()))
}
