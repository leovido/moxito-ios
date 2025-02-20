import SwiftUI
import MoxieLib

struct RefreshButton: View {
	@EnvironmentObject var claimViewModel: MoxieClaimViewModel
	@EnvironmentObject var viewModel: MoxieViewModel
	
	let progress: Double
	
	var body: some View {
		Button {
			withAnimation {
				if Int(progress * 100) == 100 {
					claimViewModel.actions.send(.dismissClaimAlert)
				} else {
					let transactionId = claimViewModel.moxieClaimModel?.transactionID ?? ""
					claimViewModel.actions.send(.checkClaimStatus(fid: viewModel.model.entityID, transactionId: transactionId))
				}
			}
		} label: {
			Text(Int(progress * 100) == 100 ? "Done" : "Refresh")
				.font(.custom("Inter", size: 18))
				.padding()
				.foregroundStyle(Color.white)
		}
		.frame(minWidth: 102)
		.frame(height: 38)
		.background(Int(progress * 100) == 100 ? Color(uiColor: MoxieColor.green) : Color(uiColor: MoxieColor.primary))
		.clipShape(Capsule())
	}
}

#Preview {
	RefreshButton(progress: 3.0)
}
