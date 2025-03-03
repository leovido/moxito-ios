import SwiftUI
import MoxieLib
import Combine
import Sentry
import DevCycle
import MoxitoLib

struct OnboardingView: View {
	@AppStorage("moxieData") var moxieData: Data = .init()
	@StateObject var authViewModel = AuthViewModel()

	@SwiftUI.Environment(\.openURL) var openURL
	@SwiftUI.Environment(\.scenePhase) var scenePhase
	@SwiftUI.Environment(\.colorScheme) var colorScheme

	@EnvironmentObject var viewModel: MoxieViewModel

//	@StateObject var featureFlagManager: FeatureFlagManager
	@StateObject var viewModelOnboarding: OnboardingViewModel = .init(isAlertShowing: false)

	var body: some View {
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

					Button(action: {
						Task {
							try await authViewModel.startLogin()
						}
					}) {
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
		.navigationSplitViewStyle(BalancedNavigationSplitViewStyle())
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

			Button {
				viewModelOnboarding.isAlertShowing = false
			} label: {
				Text("Cancel")
					.font(.custom("Inter", size: 16))
			}
		} message: {
			Text("Sign in with Farcaster will be available in the future.\n\nIn the meantime input your FID to fetch your Moxie data")
		}
		.font(.custom("Inter", size: 16))
		.onChange(of: viewModel.model, initial: false, { oldValue, newValue in
			if oldValue != newValue {
				do {
					moxieData = try CustomDecoderAndEncoder.encoder.encode(newValue)
				} catch {
					SentrySDK.capture(error: error)
				}
			}
		})
		.onAppear {
			do {
				viewModel.model = try CustomDecoderAndEncoder.decoder.decode(MoxieModel.self, from: moxieData)
				viewModel.input = viewModel.model.entityID
				viewModel.inputFID = Int(viewModel.model.entityID) ?? 0
			} catch {
				SentrySDK.capture(error: error)
			}
		}
		.onChange(of: authViewModel.isAuthenticated, initial: true) { _, newValue in
			if newValue {
				guard let url = authViewModel.url else {
					return
				}
				do {
					let fid = try authViewModel.handleDeepLink(url: url)
					viewModel.input = fid
					viewModel.inputFID = Int(fid) ?? 0
				} catch {
					SentrySDK.capture(error: error)
				}
			}
		}
		.onOpenURL { incomingURL in
			do {
				let fid = try authViewModel.handleDeepLink(url: incomingURL)
				viewModel.input = fid
				viewModel.inputFID = Int(fid) ?? 0
			} catch {
				SentrySDK.capture(error: error)
			}
		}
	}
}

#Preview {
	OnboardingView()
		.environmentObject(MoxieViewModel())
}
