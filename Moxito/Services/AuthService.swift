import AuthenticationServices
import Sentry
import MoxieLib

enum AuthError: Error {
	case invalidURL
	case authenticationFailed
	case cancelled
	case message(String)
}

final class AuthenticationService: NSObject, AuthProvider, ASWebAuthenticationPresentationContextProviding {
	func startLogin() async throws -> URL {
		guard let authURL = URL(string: "https://app.moxito.xyz") else {
			throw AuthError.invalidURL
		}

		let callbackScheme = "moxito"

		return try await withCheckedThrowingContinuation { continuation in
			let session = ASWebAuthenticationSession(url: authURL, callbackURLScheme: callbackScheme) { callbackURL, error in
				if let error = error as? ASWebAuthenticationSessionError {
					switch error.code {
					case .canceledLogin:
						continuation.resume(throwing: AuthError.cancelled)
					default:
						SentrySDK.capture(error: error)
						continuation.resume(throwing: AuthError.authenticationFailed)
					}
					return
				}

				guard let callbackURL = callbackURL else {
					continuation.resume(throwing: AuthError.authenticationFailed)
					return
				}

				continuation.resume(returning: callbackURL)
			}

			session.presentationContextProvider = self

			// Ensure the session starts successfully
			guard session.start() else {
				continuation.resume(throwing: AuthError.authenticationFailed)
				return
			}

			// Store session reference to prevent deallocation
			Task {
				await storeSession(session)
			}
		}
	}

	// Keep a reference to the active session
	private var activeSession: ASWebAuthenticationSession?

	private func storeSession(_ session: ASWebAuthenticationSession) async {
		activeSession = session
	}

	func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
		return UIApplication.shared.windows.first ?? ASPresentationAnchor()
	}
}
