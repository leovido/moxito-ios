import SwiftUI
import MoxieLib

final class OnboardingViewModel: ObservableObject {
	@Published var isAlertShowing: Bool = false
	@Published var inputTextFID: String = ""

	init(isAlertShowing: Bool) {
		self.isAlertShowing = isAlertShowing
	}
}

struct OnboardingView: View {
	var body: some View {
		LoginView()
	}
}

struct LoginView: View {
	@EnvironmentObject var viewModel: MoxieViewModel
	@StateObject var viewModelOnboarding: OnboardingViewModel = .init(isAlertShowing: false)
	
	var body: some View {
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
					.padding(.top, 24)
					.padding()

					Text("Sign in to the apps to display your profile or skip this step. If you skip this step you will only have access to the FID search.")
						.padding([.horizontal, .bottom], 16)
						.foregroundStyle(Color("OnboardingText"))
						.font(.system(size: 14))
						.multilineTextAlignment(.center)
					
					
					Button(action: {
						viewModelOnboarding.isAlertShowing = true
					}) {
						Image("SignInWarpcast", bundle: .main)
					}
					.shadow(color: Color("SignInShadow"), radius: 24, y: 8)

					Button(action: {
						
					}) {
						Text("Skip this step")
							.foregroundStyle(Color("SkipText"))
							.font(.system(size: 16))
							.padding(.vertical)
					}
				}
				.background(Color.white)
				.clipShape(RoundedRectangle(cornerSize: CGSize(width: 50, height: 50)))
				.frame(maxWidth: .infinity)
				.padding(.bottom, 54)
				.padding(.horizontal, 21)
				.shadow(color: .black.opacity(0.1), radius: 24, y: 16)
			}
			.overlay(alignment: .center, content: {
				if viewModel.isLoading {
					ProgressView()
				}
			})
			.alert("Sign in", isPresented: $viewModelOnboarding.isAlertShowing) {
				TextField("Your Farcaster ID, e.g. 203666", text: $viewModel.input)

				Text("Sign in")
			} message: {
				Text("Sign in with Farcaster will be available in the future. In the meantime input your FID to fetch your Moxie data")
			}
		}
	}
}

#Preview {
	OnboardingView()
}
