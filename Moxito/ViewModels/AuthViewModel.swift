import SwiftUI
import AuthenticationServices
import Sentry
import Combine

enum AuthViewModelError: Error, LocalizedError {
	case invalidURL
	case invalidToken
	case invalidState
	case invalidNonce
	case invalidSignature
	case invalidResponse
	case invalidResponseType
	case invalidRedirectURI
	case invalidScope
}

@MainActor
final class AuthViewModel: ObservableObject {
	@Published var isAuthenticated = false
	@Published var url: URL?
	@Published var authError: String?

	private let authService: AuthProvider
	private let keychainService: KeychainProvider
	private var subscriptions = Set<AnyCancellable>()

	init(authService: AuthProvider = AuthenticationService(),
			 keychainService: KeychainProvider = KeychainService()) {
		self.authService = authService
		self.keychainService = keychainService

		$url
			.filter({ $0 != nil })
			.sink { _ in
				self.isAuthenticated = true
			}
			.store(in: &subscriptions)
	}

	func startLogin() async throws {
		do {
			let url = try await authService.startLogin()
			self.url = url
		} catch {
			SentrySDK.capture(error: error)
		}
	}

	func handleDeepLink(url: URL) throws -> String {
		guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
					components.scheme == "moxito",
					components.host == "auth",
					let queryItems = components.queryItems else {
			throw KeychainError.message("Invalid deep link")
		}
		let signer64 = queryItems.first(where: { $0.name == "id" })?.value
		let fid64 = queryItems.first(where: { $0.name == "fid" })?.value

		if let signer = signer64, let fid = fid64 {
			if let decodedSigner = Data(base64Encoded: signer),
				 let decodedSignerString = String(data: decodedSigner, encoding: .utf8),
				 let decodedFID = Data(base64Encoded: fid),
				 let decodedFIDString = String(data: decodedFID, encoding: .utf8) {
				try keychainService.save(token: decodedSignerString, for: decodedFIDString, service: "com.christianleovido.Moxito")

				return decodedFIDString
			} else {
				SentrySDK.capture(error: AuthError.message("Failed to decode Base64 data"))
			}
		} else {
			print("Required query items missing: signer or fid.")
		}
		return ""
	}
}
