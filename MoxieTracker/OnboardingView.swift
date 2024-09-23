import SwiftUI
import MoxieLib
import Combine
import Sentry

final class OnboardingViewModel: ObservableObject {
	@Published var isAlertShowing: Bool = false
	@Published var inputTextFID: String = ""
		
	private(set) var subscriptions: Set<AnyCancellable> = []

	init(isAlertShowing: Bool) {
		self.isAlertShowing = isAlertShowing
		self.inputTextFID = ""
	}
}

struct OnboardingView: View {
	@EnvironmentObject var viewModel: MoxieViewModel
	@State private var showWebView = false

	var body: some View {
		LoginView()
	}
}

struct LoginView: View {
	@State private var showWebView = false
	@Environment(\.openURL) var openURL

	@Environment(\.colorScheme) var colorScheme
	@EnvironmentObject var viewModel: MoxieViewModel
	@StateObject var viewModelOnboarding: OnboardingViewModel = .init(isAlertShowing: false)

	var body: some View {
		NavigationView {
			ZStack {
				Image("Onboarding-BG", bundle: .main)
					.resizable() // Makes the image resizable
					.imageScale(.small)
					.ignoresSafeArea() // Extends the image beyond the safe area
				
				VStack {
					Spacer()
					VStack {
						VStack {
							Text("Sign in to your profile")
							Text("with Farcaster")
						}
						.multilineTextAlignment(.center)
						.frame(maxWidth: .infinity, alignment: .center)
						.foregroundStyle(Color(uiColor: .primary))
						.font(.custom("Inter", size: 24))
						.fontWeight(.bold)
						.padding(.top, 24)
						.padding()

						Text("Sign in to the apps to display your profile or skip this step. If you skip this step you will only have access to the FID search.")
							.padding([.horizontal, .bottom], 25)
							.foregroundStyle(Color("OnboardingText"))
							.font(.custom("Inter", size: 14))
							.multilineTextAlignment(.center)
							
						Button {
							openURL(URL(string: "https://moxito.xyz")!)
						} label: {
							Image("SignInWarpcast", bundle: .main)
						}

						.shadow(color: Color("SignInShadow"), radius: 24, y: 8)

						Button(action: {
							viewModel.model = .placeholder
						}) {
							Text("Skip this step")
								.foregroundStyle(Color("SkipText"))
								.font(.custom("Inter", size: 16))
								.padding(.vertical)
						}
					}
					.background(Color.white)
					.clipShape(RoundedRectangle(cornerSize: CGSize(width: 50, height: 50)))
					.padding(.horizontal, 21)
					.shadow(color: .black.opacity(0.1), radius: 24, y: 16)
				}
				.overlay(alignment: .center, content: {
					if viewModel.isLoading {
						ProgressView()
					}
				})
				.alert("Sign in", isPresented: $viewModelOnboarding.isAlertShowing) {
					TextField("Your Farcaster ID, e.g. 203666", text: $viewModelOnboarding.inputTextFID)
						.keyboardType(.numberPad)
						.foregroundColor(Color(.textField))
						.font(.custom("Inter", size: 16))
						.padding()
						.toolbar {
							ToolbarItemGroup(placement: .keyboard) {
								Spacer()
								Button("Done") {
									UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
								}
							}
						}
					Button {
						viewModel.input = viewModelOnboarding.inputTextFID
						viewModel.inputFID = Int(viewModelOnboarding.inputTextFID) ?? 0
					} label: {
						Text("Sign in")
							.font(.custom("Inter", size: 16))
					}

				} message: {
					Text("Sign in with Farcaster will be available in the future.\n\nIn the meantime input your FID to fetch your Moxie data")
						.font(.custom("Inter", size: 16))
				}
			}
		}
	}
}

#Preview {
	OnboardingView()
		.environmentObject(MoxieViewModel())
}
