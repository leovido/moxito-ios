import SwiftUI
import MoxieLib
import UserNotifications

struct ScheduleNotificationView: View {
	@ObservedObject var viewModel: MoxieViewModel
	
	var body: some View {
		Group {
			List {
				Section {
					Button {
						viewModel.updateNotificationOption(.hour)
					} label: {
						HStack {
							Text("Every hour")
							
							Spacer()
							
							Image(systemName: viewModel.selectedNotificationOptions.contains(NotificationOption.hour) ? "checkmark.circle" : "circle")
						}
					}
					
					Button {
						viewModel.updateNotificationOption(.week)
					} label: {
						HStack {
							Text("Every week")
							
							Spacer()
							
							Image(systemName: viewModel.selectedNotificationOptions.contains(NotificationOption.week) ? "checkmark.circle" : "circle")
						}
					}
					
					Button {
						viewModel.updateNotificationOption(.month)
					} label: {
						HStack {
							Text("Every month")
							
							Spacer()
							
							Image(systemName: viewModel.selectedNotificationOptions.contains(NotificationOption.month) ? "checkmark.circle" : "circle")
						}
					}
				} header: {
					Text("Frequency")
				}
				
				Section {
					Button {
						viewModel.isNotificationSheetPresented = true
					} label: {
						HStack {
							Text("Custom")
							
							Spacer()
						}
					}
				}
				
				Section {
					Button {
						viewModel.removeAllScheduledNotifications()
					} label: {
						HStack {
							Text("Delete")
								.foregroundStyle(Color.red)
							
							Spacer()
						}
					}
				} header: {
					Text("Delete")
				} footer: {
					Text("Deletes all scheduled notifications")
				}
			}
			.listStyle(PlainListStyle())
//			if viewModel.userInputNotifications != 0 {
//				
//			} else {
//				ContentUnavailableView {
//					Label("No scheduled notifications", systemImage: "bell.fill")
//						.foregroundStyle(Color(uiColor: MoxieColor.dark))
//				} description: {
//					Text("Keep updated with your daily $MOXIE earnings")
//						.fontDesign(.rounded)
//						.foregroundStyle(Color(uiColor: MoxieColor.textColor))
//				}
//			}
		}
		
		.sheet(isPresented: $viewModel.isNotificationSheetPresented, content: {
			VStack(alignment: .leading) {
				Section {
					Text("Enter Moxie Value for Alerts")
						.font(.largeTitle)
						.foregroundStyle(Color(uiColor: MoxieColor.dark))
						.fontDesign(.rounded)
						.bold()
					TextField("Change value",
										text: $viewModel.moxieChangeText,
										prompt: Text("e.g. 100"))
					.foregroundStyle(Color(uiColor: MoxieColor.dark))
					.fontDesign(.rounded)
					.autocorrectionDisabled()
					.textFieldStyle(RoundedBorderTextFieldStyle())
					
					Button("Save") {
						viewModel.isNotificationSheetPresented = false
						viewModel.saveCustomMoxieInput()
					}
					.font(.headline)
					.foregroundStyle(Color(uiColor: MoxieColor.dark))
					.padding()
					.frame(maxWidth: .infinity)
					.background(Color(uiColor: MoxieColor.backgroundColor))
					.border(Color(uiColor: MoxieColor.dark), width: 2)
				} footer: {
					Text("You will receive a notification every \(viewModel.moxieChangeText.isEmpty ? "x" : viewModel.moxieChangeText) $MOXIE you receive")
						.font(.caption)
						.foregroundStyle(Color(uiColor: MoxieColor.dark))
						.fontDesign(.rounded)
				}
				
				Spacer()
			}
			.padding()
			.presentationDetents([.medium, .large])
			.presentationDragIndicator(.visible)
		})
		.toolbar(.hidden, for: .tabBar)
		.padding()
		.navigationTitle("Notifications")
		.onAppear() {
			UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
					if granted {
							print("Permission granted")
					} else {
							print("Permission denied")
					}
			}
		}
	}
}

#Preview {
	NavigationStack {
		ScheduleNotificationView(viewModel: .init(client: MockMoxieClient(), userInputNotifications: 390))
	}
}
