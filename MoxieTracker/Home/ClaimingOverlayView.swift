import SwiftUI
import MoxieLib

struct ClaimingOverlayView: View {
	@EnvironmentObject var viewModel: MoxieViewModel
	@EnvironmentObject var claimViewModel: MoxieClaimViewModel
	
	let height: CGFloat
	
	var body: some View {
		VStack {
			ProgressView(value: claimViewModel.progress, total: 1.0)
				.progressViewStyle(LinearProgressViewStyle())
				.tint(Color(uiColor: MoxieColor.green))
				.padding()
				.onAppear {
					claimViewModel.startProgressTimer()
				}
				.onDisappear {
					claimViewModel.stopProgressTimer()
				}
			
			Text("Claiming... \(Int(claimViewModel.progress * 100))%")
				.font(.custom("Inter", size: 23))
				.padding()
				.foregroundStyle(Color.white)
			
			Button {
				withAnimation {
					if Int(claimViewModel.progress * 100) == 100 {
						claimViewModel.actions.send(.dismissClaimAlert)
					} else {
						let transactionId = claimViewModel.moxieClaimModel?.transactionID ?? ""
						claimViewModel.actions.send(.checkClaimStatus(fid: viewModel.model.entityID, transactionId: transactionId))
					}
				}
			} label: {
				Text(Int(claimViewModel.progress * 100) == 100 ? "Done" : "Refresh")
					.font(.custom("Inter", size: 18))
					.padding()
					.foregroundStyle(Color.white)
			}
			.frame(minWidth: 102)
			.frame(height: 38)
			.background(Int(claimViewModel.progress * 100) == 100 ? Color(uiColor: MoxieColor.green) : Color(uiColor: MoxieColor.primary))
			.clipShape(Capsule())
		}
		.frame(height: height)
		.background(Color(uiColor: MoxieColor.primary).opacity(0.8))
		.transition(.opacity)
	}
}
