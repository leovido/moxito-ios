import SwiftUI
import MoxieLib
import Combine

@MainActor
public final class SearchViewModel: ObservableObject {
	public let client: FarcasterClient

	@Published var currentFID: Int = 3
	@Published var query: String = ""
	@Published var items: [User]
	@Published var isLoading: Bool = false
	@Published var task: Task<Void, Never>?

	private(set) var subscriptions: [AnyCancellable] = []

	public init(client: FarcasterClient,
							query: String,
							items: [User],
							currentFID: Int) {
		self.client = client
		self.query = query
		self.items = items
		self.currentFID = currentFID

		setupListeners()
	}

	public func setupListeners() {
		$query
			.debounce(for: .seconds(0.5), scheduler: RunLoop.main)
			.filter({
				$0.count >= 3
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
		task?.cancel()
		isLoading = true
		task = Task {
			do {
				items = try await client.searchUsername(username: query, limit: 10).result.users
				isLoading = false
			} catch {
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
				Color(uiColor: .systemGray6)
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
											.aspectRatio(contentMode: .fill)
											.clipShape(Circle())
											.frame(width: 65, height: 65)
									}, placeholder: {
										ProgressView()
									})
									.padding(.trailing, 8)

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
							MiniSearchView(viewModel: .init(
								input: userFID.description,
								isSearchMode: true))
							.navigationBarTitleDisplayMode(.inline)
						})
					}
				}
				.redacted(reason: viewModel.isLoading ? .placeholder : [])
				.navigationTitle("Search")
				.navigationBarTitleDisplayMode(.inline)
				.refreshable {
					viewModel.searchUser()
				}
				.searchable(text: $viewModel.query, prompt: "e.g. username")
				.autocorrectionDisabled()
			}
		}
		.tint(Color.primary)
		.tabItem {
			Label("Search", systemImage: "magnifyingglass")
		}
	}
}

#Preview {
	Text("Moxito")
		.sheet(isPresented: .constant(true)) {
			SearchListView(viewModel: .init(client: FarcasterClient(), query: "leovido", items: [], currentFID: 3))
		}
}
