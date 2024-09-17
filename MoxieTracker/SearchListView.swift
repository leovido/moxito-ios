import SwiftUI
import MoxieLib
import Combine

@MainActor
public final class SearchViewModel: ObservableObject {
	public let client: FarcasterClient
	
	@Published var query: String = ""
	@Published var items: [User]
	@Published var isLoading: Bool = false
	
	private(set) var subscriptions: [AnyCancellable] = []
	
	public init(client: FarcasterClient,
							query: String,
							items: [User]) {
		self.client = client
		self.query = query
		self.items = items
		
		setupListeners()
	}
	
	public func setupListeners() {
		$query
			.debounce(for: .seconds(0.5), scheduler: RunLoop.main)
			.filter({
				!$0.isEmpty
			})
			.sink { _ in
				self.searchUser()
			}
			.store(in: &subscriptions)
		
		$query
			.sink { queryValue in
				if queryValue.isEmpty {
					self.items = []
				}
			}
			.store(in: &subscriptions)
	}
	
	public func searchUser() {
		isLoading = true
		Task {
			do {
				items = try await client.searchUsername(username: query, viewerFid: 203666, limit: 10).result.users
				
				isLoading = false
			} catch {
				dump(error)
				isLoading = false
			}
		}
	}
}

public struct SearchListView: View {
	@StateObject var viewModel: SearchViewModel
	
	public var body: some View {
		NavigationStack {
			ZStack {
				Color(uiColor: MoxieColor.backgroundColor)
					.ignoresSafeArea(.all)
				Group {
					if viewModel.items.isEmpty {
						ContentUnavailableView(
							"FC users search",
							systemImage: "magnifyingglass",
							description: Text("Search for any Farcaster user"))
					} else {
						List(viewModel.items) { item in
							NavigationLink(value: item.fid) {
								HStack {
									AsyncImage(url: URL(string: item.pfpURL),
														 content: { image in
										image
											.resizable()
											.aspectRatio(contentMode: .fit)
											.clipShape(Circle())
											.frame(width: 50, height: 50)
									}, placeholder: {
										ProgressView()
									})
									
									VStack(alignment: .leading) {
										Text(item.displayName ?? "")
											.font(.headline)
										Text(item.username ?? "")
											.font(.subheadline)
										Text(item.fid.description)
											.fontWeight(.light)
											.font(.caption)
									}
								}
							}
						}
						.navigationDestination(for: Int.self, destination: { userFID in
							HomeView()
							.navigationBarTitleDisplayMode(.inline)
						})
					}
				}
				.redacted(reason: viewModel.isLoading ? .placeholder : [])
				.navigationTitle("Search")
				.refreshable {
					viewModel.searchUser()
				}
				.searchable(text: $viewModel.query, prompt: "e.g. username")
				.autocorrectionDisabled()
			}
		}
		.tabItem {
			Label("Search", systemImage: "magnifyingglass")
		}
	}
}

#Preview {
	SearchListView(viewModel: .init(client: FarcasterClient(), query: "leovido", items: []))
}
