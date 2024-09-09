import SwiftUI
import MoxieLib

struct SettingsView: View {
	@ObservedObject var viewModel: MoxieViewModel
	
	var body: some View {
		NavigationStack {
			ZStack {
				VStack {
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
					
					Button(action: {
						// Your action here
					}) {
						Text("Logout")
							.foregroundColor(Color(uiColor: .primary))
							.frame(maxWidth: .infinity)
							.frame(height: 64)
						
					}
					.clipShape(RoundedRectangle(cornerRadius: 32))
					.foregroundColor(Color(uiColor: .primary))
					.frame(maxWidth: .infinity)
					.overlay(
						RoundedRectangle(cornerRadius: 32)
							.stroke(Color(uiColor: .primary.withAlphaComponent(0.5)), lineWidth: 1)
					)
					.padding(.bottom)
					
					Text("Moxito © 2024 v1.0")
						.background(Color.clear)
						.foregroundStyle(Color(uiColor: .systemGray4))
						.padding(.bottom, 8)
				}
				.padding(.horizontal)
				.background(Color(uiColor: .systemGray6))
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
