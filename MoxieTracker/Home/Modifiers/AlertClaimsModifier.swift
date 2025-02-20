import SwiftUI

struct AlertClaimsModifier: ViewModifier {
	@EnvironmentObject var viewModel: MoxieViewModel
	@EnvironmentObject var claimViewModel: MoxieClaimViewModel
	
	let availableClaimAmountFormatted: String
	
	func body(content: Content) -> some View {
		content
			.alert("Wallet confirmation", isPresented: $claimViewModel.isClaimAlertShowing) {
				Button("Yes") {
					claimViewModel.actions.send(.claimRewards(fid: viewModel.model.entityID, wallet: claimViewModel.selectedWallet))
				}
				Button("No") {
					claimViewModel.actions.send(.initiateClaim(.home))
				}
			} message: {
				Text("Do you want to use \(claimViewModel.selectedWalletDisplay) to claim?")
			}
			.alert("Moxie claim success", isPresented: $claimViewModel.isClaimSuccess) {
				Button("Let's go!🚀") {
					viewModel.confettiCounter += 1
				}
			} message: {
				Text("\(availableClaimAmountFormatted) $MOXIE successfully claimed 🌱")
			}
	}
}
