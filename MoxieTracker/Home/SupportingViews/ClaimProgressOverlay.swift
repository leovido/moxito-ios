import SwiftUI
import MoxieLib

struct ClaimProgressOverlay: View {
	@EnvironmentObject var viewModel: MoxieViewModel
	@EnvironmentObject var claimViewModel: MoxieClaimViewModel
	
	let isShowing: Bool
	let progress: Double
	let height: CGFloat
	
	var body: some View {
		if isShowing {
			VStack {
				ProgressView(value: progress, total: 1.0)
					.progressViewStyle(LinearProgressViewStyle())
					.tint(Color(uiColor: MoxieColor.green))
					.padding()
					.onAppear { claimViewModel.startProgressTimer() }
					.onDisappear { claimViewModel.stopProgressTimer() }
				
				Text("Claiming... \(Int(progress * 100))%")
					.font(.custom("Inter", size: 23))
					.padding()
					.foregroundStyle(Color.white)
				
				RefreshButton(progress: progress)
			}
			.frame(height: height)
			.background(Color(uiColor: MoxieColor.primary).opacity(0.8))
			.transition(.opacity)
			.preference(key: ClaimStatePreferenceKey.self,
									value: .claiming(progress: progress))
		}
	}
}

#Preview {
	ClaimProgressOverlay(isShowing: true, progress: 0.5, height: 100)
}
