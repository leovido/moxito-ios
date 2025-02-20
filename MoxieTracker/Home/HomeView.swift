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
					Color(uiColor: MoxieColor.primary)
						.ignoresSafeArea()
					Image("wave", bundle: .main)
						.resizable()
						.ignoresSafeArea()
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
					.padding()
					.confirmationDialog("Moxie claim",
															isPresented: $claimViewModel.isClaimDialogShowing,
															titleVisibility: .visible) {
						ForEach(viewModel.wallets, id: \.self) { wallet in
							Button(wallet) {
								claimViewModel.actions.send(.selectedWallet(wallet))
							}
						}
					} message: {
						Text("Choose wallet for claiming Moxie")
					}
					.redacted(reason: viewModel.isLoading ? .placeholder : [])
					.overlay(alignment: .center) {
						ClaimProgressOverlay(
							isShowing: claimViewModel.isClaimRequested,
							progress: claimViewModel.progress,
							height: geo.size.height
						)
					}
					.modifier(AlertClaimsModifier(availableClaimAmountFormatted: availableClaimAmountFormatted))
					.modifier(HomeStateManagerModifier())
					.sensoryFeedback(.selection, trigger: claimViewModel.number)
					.sensoryFeedback(.success, trigger: claimViewModel.isClaimAlertShowing, condition: { _, newValue in
						return !newValue
					})
					.confettiCannon(counter: $viewModel.confettiCounter, num: 1,
													confettis: [.text("🍃")],
													confettiSize: 30, repetitions: 50, repetitionInterval: 0.1)
					.onAppear {
						Task {
							try await viewModel.fetchPrice()
							viewModel.timeAgoDisplay()
						}
					}
					.onAppear {
						SentrySDK.setUser(.init(userId: viewModel.model.entityID))
					}
					.overlay(alignment: .top) {
						if viewModel.error != nil {
							ErrorView(error: $viewModel.error)
						}
					}
					.refreshable {
						Task {
							try await viewModel.fetchPrice()
							try await viewModel.fetchStats(filter: MoxieFilter(rawValue: viewModel.filterSelection) ?? .today)
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

#Preview {
	HomeView()
		.environment(MoxieViewModel(model: .placeholder, client: MockMoxieClient()))
}

