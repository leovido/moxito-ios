import SwiftUI
import MoxieLib
import Sentry

struct HeaderView: View {
	@EnvironmentObject var viewModel: MoxieViewModel
	@EnvironmentObject var claimViewModel: MoxieClaimViewModel

	let tab: Tab

	var body: some View {
		HStack {
			VStack(alignment: .leading) {
				Text("\(viewModel.isSearchMode ? viewModel.model.socials.profileDisplayName ?? "Moxie" : "Hello, " + (viewModel.model.socials.profileDisplayName ?? "Moxie"))")
					.scaledToFit()
					.font(.body)
					.font(.custom("Inter", size: 20))
					.foregroundStyle(Color.white)
					.fontWeight(.bold)
					.multilineTextAlignment(.leading)
				Text("Last update: \(viewModel.timeAgo)")
					.fontWeight(.light)
					.foregroundStyle(Color.white)
					.font(.caption)
					.font(.custom("Inter", size: 20))
					.multilineTextAlignment(.leading)
			}
			Spacer()

			Button(action: {
				withAnimation {
					claimViewModel.number = viewModel.model.moxieClaimTotals.first?.availableClaimAmount ?? 0
					claimViewModel.progress = 0
					Haptics.shared.play(.medium)
					SentrySDK.capture(message: "Claimed Moxie")

					Task {
						claimViewModel.actions.send(.initiateClaim(tab))
					}
				}
			}, label: {
				Text(viewModel.model.moxieClaimTotals.first?.availableClaimAmount == 0 ? "Claimed" : "Claim")
					.foregroundStyle(.white)
					.padding(16)
			})
			.disabled(viewModel.model.moxieClaimTotals.first?.availableClaimAmount ?? 0 == 0)
			.frame(minWidth: 102)
			.frame(height: 38)
			.font(.callout)
			.background(viewModel.model.moxieClaimTotals.first?.availableClaimAmount != 0 ? Color(uiColor: MoxieColor.green) : Color(uiColor: MoxieColor.claimButton))
			.clipShape(Capsule())

			NavigationLink {
				AccountView()
			} label: {
				Image("GearUnselected")
					.resizable()
					.renderingMode(.template)
					.aspectRatio(contentMode: .fit)
					.frame(width: 20, height: 20)
					.foregroundStyle(Color(uiColor: MoxieColor.primary))
			}
			.frame(width: 38, height: 38)
			.font(.callout)
			.background(Color.white)
			.clipShape(Circle())
		}
		.padding(.bottom, 20)
	}
}
