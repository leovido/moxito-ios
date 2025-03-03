import Foundation

public enum FCEndpoint {
	static let usersEndpoint = "https://api.neynar.com/v2/farcaster/user/search"
}

public protocol FarcasterProvider {
	func searchUsername(username: String, limit: Int) async throws -> FarcasterUser
}

public final class FarcasterClient: FarcasterProvider {
	private let session: URLSession

	public init(session: URLSession = .init(configuration: .default, delegate: nil, delegateQueue: nil)) {
		self.session = session
		
		session.configuration.urlCache = URLCache(memoryCapacity: 512000, diskCapacity: 10240000, diskPath: nil)
		session.configuration.requestCachePolicy = .returnCacheDataElseLoad
	}
	
	public func searchUsername(username: String, limit: Int = 5) async throws -> FarcasterUser {
		do {
			guard let url = URL(string: FCEndpoint.usersEndpoint),
						let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
				throw MoxieError.message("Invalid")
			}
			
			var request = URLRequest(url: components.url!)
			request.cachePolicy = .useProtocolCachePolicy
			
			request.url?.append(queryItems: [
				.init(name: "q", value: username),
				.init(name: "limit", value: limit.description)
			])
			
			request.setValue( Bundle.main.infoDictionary?["NEYNAR_API_KEY"] as? String ?? "", forHTTPHeaderField: "api_key")
			
			let (data, _) = try await session.data(for: request)
			let decoder = JSONDecoder()
			
			let model = try decoder.decode(FarcasterUser.self, from: data)
			
			return model
		} catch {
			throw error
		}
	}
}
