import SwiftUI
import PrivySignIn
import PrivySDK
import MoxieLib
import Combine

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
	var body: some View {
		LoginView()
	}
}

struct LoginView: View {
	@EnvironmentObject var privyClient: PrivyClient

	@State private var showWebView = false
	
	@Environment(\.colorScheme) var colorScheme
	@EnvironmentObject var viewModel: MoxieViewModel
	@StateObject var viewModelOnboarding: OnboardingViewModel = .init(isAlertShowing: false)
	
	var body: some View {
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
//						Task {
//							let signature = try! await siweCreateSignature()
//							dump(signature)
//						}
						viewModelOnboarding.isAlertShowing = true
					}) {
						Image("SignInWarpcast", bundle: .main)
					}
					.shadow(color: Color("SignInShadow"), radius: 24, y: 8)
//					.fullScreenCover(isPresented: $showWebView, content: {
//						WebView(neynarLoginUrl: "https://toth-frame.vercel.app/", clientId: "13f73c6f-f90f-40c6-bb70-b4946129cd7c", redirectUri: "") { data in
//							print("Authentication successful with data: \(data)")
//							showWebView = false
//						}
//					})

					Button(action: {
						viewModel.model = .placeholder
					}) {
						Text("Skip this step")
							.foregroundStyle(Color("SkipText"))
							.font(.system(size: 16))
							.padding(.vertical)
					}
				}
				.background(Color.white)
				.clipShape(RoundedRectangle(cornerSize: CGSize(width: 50, height: 50)))
//				.padding(.bottom, 54)
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
				}

			} message: {
				Text("Sign in with Farcaster will be available in the future.\n\nIn the meantime input your FID to fetch your Moxie data")
			}
		}
	}
	
	func siweCreateSignature() async throws -> String {
		do {
			let params = SiweMessageParams(
				appDomain: "com.christianleovido.Moxito",
				appUri: "https://moxito.xyz",
				chainId: "5453",
				walletAddress: "0xdd3b3A67C66A5276aaCC499ec2abD5241721e008"
			)
			
			let metadata = WalletLoginMetadata(
				walletClientType: WalletClientType.metamask,
				connectorType: "wallet_connect"
			)
			
			let siweMessage = try await privyClient.privy.siwe.generateSiweMessage(params: params, metadata: metadata)
			
			return siweMessage
		} catch let error {
			dump(error)
			// An error can be thrown if the network call to generate the message fails,
			// or if invalid metadata was passed in.
		}
		
		return ""
	}
	
	func siweLink(signature: String) async throws -> AuthState {
		do {
			let authState = try await privyClient.privy.siwe.loginWithSiwe(signature)
			
			return authState
		} catch let error {
			dump(error)
		}
		
		return .notReady
	}
}

#Preview {
	OnboardingView()
		.environmentObject(MoxieViewModel.init())
}
