import SwiftUI
import AuthenticationServices

final class AuthViewModel: NSObject, ObservableObject, ASWebAuthenticationPresentationContextProviding {
	
	@EnvironmentObject var viewModel: MoxieViewModel
	
	@Published var isAuthenticated = false
	@Published var url: URL?
	@Published var authError: String?
	
	func startLogin() {
		let authURL = URL(string: "https://app.moxito.xyz")!
		let callbackScheme = "moxito"
		
		let session = ASWebAuthenticationSession(url: authURL, callbackURLScheme: callbackScheme) { callbackURL, error in
			if let error = error {
				DispatchQueue.main.async {
					self.authError = error.localizedDescription
				}
				return
			}
			
			if let callbackURL = callbackURL {
				DispatchQueue.main.async {
					self.url = callbackURL
					self.isAuthenticated = true
				}
			}
		}
		
		session.presentationContextProvider = self
		session.start()
	}
	
	func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
		return UIApplication.shared.windows.first ?? ASPresentationAnchor()
	}
}
