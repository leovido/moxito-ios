import Foundation

public final class CacheManager {
	private let urlCache: URLCache
	
	public init(cache: URLCache = .shared) {
		self.urlCache = cache
	}
	
	/// Checks the cache for an existing response.
	func cachedResponse(for request: URLRequest) -> Data? {
		if let cachedResponse = urlCache.cachedResponse(for: request) {
			return cachedResponse.data
		}
		return nil
	}
	
	/// Stores a new response in the cache.
	func storeResponse(_ data: Data, for request: URLRequest, response: URLResponse) {
		let cachedResponse = CachedURLResponse(response: response, data: data)
		urlCache.storeCachedResponse(cachedResponse, for: request)
	}
	
	/// Clears the cache for a specific request.
	func clearCache(for request: URLRequest) {
		urlCache.removeCachedResponse(for: request)
	}
	
	/// Performs a request and updates the cache if the response is different.
	func fetchData(for request: URLRequest, forceRemote: Bool) async throws -> Data {
		if forceRemote {
			let (data, response) = try await URLSession.shared.data(for: request)
			storeResponse(data, for: request, response: response)
			return data
		}
		if let cachedData = cachedResponse(for: request) {
			return cachedData
		}
		
		let (data, response) = try await URLSession.shared.data(for: request)
		storeResponse(data, for: request, response: response)
		return data
	}
}
