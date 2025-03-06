import SwiftUI
import Sentry
import MoxieLib
import MoxitoLib

struct HomeStateManagerModifier: ViewModifier {
	@EnvironmentObject var viewModel: MoxieViewModel
	@EnvironmentObject var claimViewModel: MoxieClaimViewModel

	@StateObject private var storage: StorageState = .init()

	@Environment(\.scenePhase) var scenePhase

	// swiftlint:disable cyclomatic_complexity
	func body(content: Content) -> some View {
		content
			.onChange(of: scenePhase) { _, newPhase in
				if newPhase == .active {
					Task {
						await viewModel.onAppear()
					}
				} else if newPhase == .inactive {
					print("Inactive")
				} else if newPhase == .background {
					print("Background")
				}
			}
			.onChange(of: claimViewModel.willPlayAnimationNumbers, { _, newValue in
				if newValue {
					Task {
						try await viewModel.fetchStats(filter: MoxieFilter(rawValue: viewModel.filterSelection) ?? .today)
					}
				}
			})
			.onChange(of: viewModel.model, initial: true, { oldValue, newValue in
				if oldValue != newValue {
					do {
						storage.moxieData = try CustomDecoderAndEncoder.encoder.encode(newValue)
					} catch {
						SentrySDK.capture(error: error)
					}
				}
			})
			.onChange(of: viewModel.userInputNotifications, initial: false, { oldValue, newValue in
				if oldValue != newValue {
					storage.userInputNotificationsString = newValue.formatted(.number.precision(.fractionLength(0)))
				}
			})
			.onChange(of: viewModel.selectedNotificationOptions, initial: true, { oldValue, newValue in
				if oldValue != newValue {
					do {
						storage.selectedNotificationOptionsData = try CustomDecoderAndEncoder.encoder.encode(viewModel.selectedNotificationOptions)
					} catch {
						SentrySDK.capture(error: error)
					}
				}
			})
			.onAppear {
				do {
					if storage.selectedNotificationOptionsData == Data() {
						let currentSelectedNotificationOptions = try CustomDecoderAndEncoder.decoder.decode([NotificationOption].self, from: storage.selectedNotificationOptionsData)

						viewModel.selectedNotificationOptions = currentSelectedNotificationOptions
					}

				} catch {
					SentrySDK.capture(error: error)
				}
			}
	}
	// swiftlint:enable cyclomatic_complexity
}
