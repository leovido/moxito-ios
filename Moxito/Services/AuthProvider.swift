import Foundation

protocol AuthProvider {
	func startLogin() async throws -> URL
}
