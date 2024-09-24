import SwiftUI
import MoxieLib
import Combine
import Sentry

struct OnboardingView: View {
	@AppStorage("moxieData") var moxieData: Data = .init()

	@Environment(\.openURL) var openURL
	@Environment(\.scenePhase) var scenePhase
	@Environment(\.colorScheme) var colorScheme
	@EnvironmentObject var viewModel: MoxieViewModel

	var body: some View {
		NavigationView {
			ZStack {
				Image("Onboarding-BG", bundle: .main)
					.resizable()
					.imageScale(.small)
					.ignoresSafeArea()
				
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
			}
			.onChange(of: viewModel.model, initial: false, { oldValue, newValue in
				if oldValue != newValue {
					do {
						moxieData = try CustomDecoderAndEncoder.encoder.encode(newValue)
					} catch {
						SentrySDK.capture(error: error)
					}
				}
			})
			.onAppear() {
				do {
					viewModel.model = try CustomDecoderAndEncoder.decoder.decode(MoxieModel.self, from: moxieData)
				} catch {
					SentrySDK.capture(error: error)
				}
			}
		}
	}
}

#Preview {
	OnboardingView()
		.environmentObject(MoxieViewModel())
}
