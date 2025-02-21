import SwiftUI
import MoxieLib

struct ClaimBalanceView: View {
	@EnvironmentObject var claimViewModel: MoxieClaimViewModel
	@EnvironmentObject var viewModel: MoxieViewModel

	var body: some View {
		VStack(alignment: .center) {
			if viewModel.model.socials.first?.profileImage != nil {
				AsyncImage(url: URL(string: viewModel.model.socials.first!.profileImage),
									 content: { image in
					image
						.resizable()
						.aspectRatio(contentMode: .fit)
						.clipShape(Circle())
				}, placeholder: {
					ProgressView()
				})
				.frame(width: 100, height: 100)
				.padding(.top, -8)
			}

			Text("Your claimable balance is")
				.scaledToFit()
				.font(.footnote)
				.font(.custom("Inter", size: 13))
				.foregroundStyle(Color(uiColor: MoxieColor.primary))

			HStack {
				Text("\(claimViewModel.willPlayAnimationNumbers ? claimViewModel.number.formatted(.number.precision(.fractionLength(0))) : viewModel.model.moxieClaimTotals.first?.availableClaimAmount.formatted(.number.precision(.fractionLength(0))) ?? "0 $MOXIE")")
					.font(.largeTitle)
					.font(.custom("Inter", size: 20))
					.foregroundStyle(Color(uiColor: MoxieColor.primary))
					.fontWeight(.heavy)
					.onChange(of: claimViewModel.willPlayAnimationNumbers, initial: true) { _, newValue in
						if newValue {
							claimViewModel.startCountdown()
						}
					}

				Image("CoinMoxiePurple", bundle: .main)
					.resizable()
					.aspectRatio(contentMode: .fit)
					.frame(width: 20, height: 20)
			}
			Text("~$\(viewModel.dollarValueMoxie.formatted(.number.precision(.fractionLength(2))))")
				.font(.caption)
				.font(.custom("Inter", size: 12))
				.foregroundStyle(Color(uiColor: MoxieColor.primary))
		}
		.frame(maxWidth: .infinity, maxHeight: 182)
		.padding(.vertical, 20)
		.background(Color.white)
		.clipShape(RoundedRectangle(cornerRadius: 24))
	}
}
