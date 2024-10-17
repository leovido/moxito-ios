import Foundation

public final class WidgetClient {
	private let session: URLSession

	public init(session: URLSession = .init(configuration: .default, delegate: nil, delegateQueue: nil)) {
		self.session = session
		
		session.configuration.urlCache = URLCache(memoryCapacity: 512_000, diskCapacity: 10_240_000, diskPath: nil)
		session.configuration.requestCachePolicy = .returnCacheDataElseLoad
	}
	
	public func checkEligibility(fid: String) async throws -> CherylWidgetModel {
		guard let url = URL(string: MoxieEndpoint.cherylWidgetEligible),
					var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
			throw MoxieError.message("Invalid configuration")
		}
		
		components.queryItems = [
			URLQueryItem(name: "fid", value: fid)
		]
		
		guard let urlComponent = components.url else {
			throw MoxieError.message("Invalid configuration")
		}
		
		let (data, _) = try await session.data(from: urlComponent)
		let model = try JSONDecoder().decode(CherylWidgetModel.self, from: data)
		
		return model
	}
}
