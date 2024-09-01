import SwiftUI
import MoxieLib
import UserNotifications

struct ScheduleNotificationView: View {
	@ObservedObject var viewModel: MoxieViewModel
	@State private var isSheetPresented = false
	
	var body: some View {
		VStack(alignment: .leading) {
			ContentUnavailableView {
				Label("No scheduled notifications", systemImage: "bell.fill")
					.foregroundStyle(Color(uiColor: MoxieColor.dark))
			} description: {
				Text("Keep updated with your daily $MOXIE earnings")
					.fontDesign(.rounded)
					.foregroundStyle(Color(uiColor: MoxieColor.textColor))
			}
			Spacer()
			
		}
		.sheet(isPresented: $isSheetPresented, content: {
			Section {
				Text("Value in $MOXIE change")
					.font(.headline)
				TextField("Change value", 
									text: $viewModel.moxieChangeText,
									prompt: Text("e.g. 100"))
					.textFieldStyle(RoundedBorderTextFieldStyle())
			} footer: {
				Text("You will receive a notification every \(viewModel.moxieChangeText.isEmpty ? "x" : viewModel.moxieChangeText) $MOXIE you receive")
					.font(.caption)
			}
			.presentationDetents([.medium, .large])
			.presentationDragIndicator(.visible)
			.toolbar {
				ToolbarItem(placement: .bottomBar) {
					Button("Save") {
						print("Pressed")
					}
					.font(.headline)
					.foregroundStyle(Color(uiColor: MoxieColor.dark))
					.padding()
					.frame(maxWidth: .infinity)
					.background(Color(uiColor: MoxieColor.backgroundColor))
					.border(Color(uiColor: MoxieColor.dark), width: 2)
					
				}
			}
		})
		.toolbar {
			ToolbarItem(placement: .topBarTrailing) {
				Button(action: {
					isSheetPresented.toggle()
				}, label: {
					Image(systemName: "plus")
				})
			}
		}
		.toolbar(.hidden, for: .tabBar)
		.padding()
		.navigationTitle("Schedule notifications")
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
		ScheduleNotificationView(viewModel: .init(client: MockMoxieClient()))
	}
}
