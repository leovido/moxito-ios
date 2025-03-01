import SwiftUI
import WidgetKit
import MoxieLib
import Sentry

extension Bundle {
	var releaseVersionNumber: String? {
		return infoDictionary?["CFBundleShortVersionString"] as? String
	}
	var buildVersionNumber: String? {
		return infoDictionary?["CFBundleVersion"] as? String
	}
}

struct SettingsView: View {
	@AppStorage("moxieData") var moxieData: Data = .init()
	@ObservedObject var viewModel: MoxieViewModel

	var version: String {
		Bundle.main.releaseVersionNumber ?? "1.0.0"
	}

	var buildVersionNumber: String {
		Bundle.main.buildVersionNumber ?? "1"
	}

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
						viewModel.model = .noop
						viewModel.inputFID = 0

						moxieData = Data()
						SentrySDK.setUser(.init(userId: ""))

						WidgetCenter.shared.reloadAllTimelines()
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
					.padding(.horizontal)

					Text("Moxito © 2024 v\(version) (\(buildVersionNumber))")
						.background(Color.clear)
						.foregroundStyle(Color(uiColor: .systemGray4))
						.padding(.bottom, 8)
				}
				.background(Color(uiColor: .systemGray6))
				.navigationTitle("Settings")
			}
		}
		.toolbar(.hidden, for: .tabBar)
		.tabItem {
			Label("Settings", systemImage: "gearshape")
		}
	}
}

#Preview {
	SettingsView(viewModel: .init(client: MockMoxieClient()))
}
