import SwiftUI
import WidgetKit
import MoxieLib
import ConfettiSwiftUI
import Sentry
import MoxitoLib

struct HomeView: View {
	@EnvironmentObject var viewModel: MoxieViewModel
	@EnvironmentObject var claimViewModel: MoxieClaimViewModel

	var availableClaimAmountFormatted: String {
		guard let claim = viewModel.model.moxieClaimTotals.first else {
			return ""
		}
		return claim.availableClaimAmount.formatted(.number.precision(.fractionLength(0)))
	}

	var body: some View {
		NavigationStack {
			GeometryReader { geo in
				ZStack {
					BackgroundView()

					MainContentView(geo: geo)
						.padding()
						.modifier(ClaimModifier(wallets: viewModel.wallets))
						.redacted(reason: viewModel.isLoading ? .placeholder : [])
						.claimOverlay(isShowing: claimViewModel.isClaimRequested,
												progress: claimViewModel.progress,
												height: geo.size.height)
						.modifier(AlertClaimsModifier(availableClaimAmountFormatted: availableClaimAmountFormatted))
						.modifier(HomeStateManagerModifier())
						.feedbackModifiers(claimViewModel: claimViewModel)
						.confettiEffect(counter: $viewModel.confettiCounter)
						.onAppear {
							Task {
								try await viewModel.fetchInitialData()
								SentrySDK.setUser(.init(userId: viewModel.model.entityID))
							}
						}
						.errorOverlay(error: $viewModel.error)
						.refreshable {
							Task {
								try await viewModel.refreshData()
							}
						}
				}

				if claimViewModel.isClaimRequested {
					ClaimingOverlayView(height: geo.size.height)
				}
			}
		}
		.tabItem {
			Image(systemName: "house.fill")
		}
	}
}

// MARK: - Extracted Views
private struct BackgroundView: View {
	var body: some View {
		ZStack {
			Color(uiColor: MoxieColor.primary)
				.ignoresSafeArea()
			Image("wave", bundle: .main)
				.resizable()
				.ignoresSafeArea()
		}
	}
}

private struct MainContentView: View {
	@EnvironmentObject var viewModel: MoxieViewModel
	let geo: GeometryProxy

	var body: some View {
		VStack {
			HeaderView(tab: .home)

			ScrollView(showsIndicators: false) {
				ClaimBalanceView()
				VotingInfoView()
				FilterButtonsView(filterSelection: $viewModel.filterSelection)
				EarningsCardsView()
			}
			.padding(.bottom, 50)
			Spacer()
		}
	}
}

struct ClaimModifier: ViewModifier {
	@EnvironmentObject var viewModel: MoxieClaimViewModel
	let wallets: [String]

	func body(content: Content) -> some View {
		content
			.confirmationDialog("Moxie claim",
													isPresented: $viewModel.isClaimDialogShowing,
												 titleVisibility: .visible) {
			 ForEach(wallets, id: \.self) { wallet in
				 Button(wallet) {
					 viewModel.actions.send(.selectedWallet(wallet))
				 }
			 }
		 } message: {
			 Text("Choose wallet for claiming Moxie")
		 }
	}
}

// MARK: - View Extensions
extension View {
	func claimOverlay(isShowing: Bool, progress: Double, height: CGFloat) -> some View {
		overlay(alignment: .center) {
			ClaimProgressOverlay(
				isShowing: isShowing,
				progress: progress,
				height: height
			)
		}
	}

	func feedbackModifiers(claimViewModel: MoxieClaimViewModel) -> some View {
		self
			.sensoryFeedback(.selection, trigger: claimViewModel.number)
			.sensoryFeedback(.success, trigger: claimViewModel.isClaimAlertShowing) { _, newValue in
				return !newValue
			}
	}

	func confettiEffect(counter: Binding<Int>) -> some View {
		confettiCannon(counter: counter, num: 1,
										confettis: [.text("🍃")],
										confettiSize: 30, repetitions: 50, repetitionInterval: 0.1)
	}

	func errorOverlay(error: Binding<Error?>) -> some View {
		overlay(alignment: .top) {
			if error.wrappedValue != nil {
				ErrorView(error: error)
			}
		}
	}
}

// Add to ViewModel
extension MoxieViewModel {
	func fetchInitialData() async throws {
		try await fetchPrice()
		timeAgoDisplay()
	}

	func refreshData() async throws {
		try await fetchPrice()
		try await fetchStats(filter: MoxieFilter(rawValue: filterSelection) ?? .today)
	}
}

#Preview {
	HomeView()
		.environment(MoxieViewModel(model: .placeholder, client: MockMoxieClient()))
		.environmentObject(MoxieClaimViewModel())
}
