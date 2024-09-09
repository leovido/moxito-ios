import SwiftUI
import MoxieLib

struct OnboardingView: View {
	@ObservedObject var viewModel: MoxieViewModel
	
	var body: some View {
		NavigationStack {
			ZStack {
				Image("Onboarding-BG", bundle: .main)
					.resizable() // Makes the image resizable
					.scaledToFill() // Ensures the image scales to fill the available space
					.ignoresSafeArea() // Extends the image beyond the safe area
					.frame(maxWidth: .infinity, maxHeight: .infinity) // Ensures the image takes all available space
				
				VStack {
					Spacer()

					VStack {
						VStack {
							Text("Sign in to your profile")
							Text("with Farcaster")
						}
						.multilineTextAlignment(.center) // Align text to the left (or choose .center / .trailing)
						.frame(maxWidth: .infinity, alignment: .center) // Adjust width as needed
						.foregroundStyle(Color(uiColor: .primary))
						.font(.system(size: 24))
						.fontWeight(.bold)
						.padding()
						
						Text("Sign in to the apps to display your profile or skip this step. If you skip this step you will only have access to the FID search.")
							.padding([.horizontal, .bottom], 16)
							.foregroundStyle(Color("OnboardingText"))
							.font(.system(size: 14))
							.multilineTextAlignment(.center)
						
						
						Button(action: {
							viewModel.input = "203666"
						}) {
							Image("SignInWarpcast", bundle: .main)
						}
						.padding(.bottom)
					}
					.background(Color.white)
					.clipShape(RoundedRectangle(cornerSize: CGSize(width: 50, height: 50)))
					.frame(maxWidth: .infinity)
					.padding(.bottom, 54)
					.padding(.horizontal, 21)
				}
			}
		}
	}
}

#Preview {
	OnboardingView(viewModel: MoxieViewModel(client: MockMoxieClient()))
}
