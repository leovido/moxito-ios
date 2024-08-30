import SwiftUI
import MoxieLib
import Combine

enum CustomDecoderAndEncoder {
	static var decoder: JSONDecoder {
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601
		
		return decoder
	}
	
	static var encoder: JSONEncoder {
		let encoder = JSONEncoder()
		encoder.dateEncodingStrategy = .iso8601
		
		return encoder
	}
}

@MainActor
final class MoxieViewModel: ObservableObject {
	@Published var input = ""
	@Published var model: MoxieModel
	@Published var isLoading: Bool = false
	@Published var price: Decimal = 0
	
	@Published var dollarValueMoxie: Decimal = 0

	@Published var inputFID: Int = -1
	
	let client: MoxieProvider
	
	private(set) var subscriptions: Set<AnyCancellable> = []

	init(input: String = "", 
			 model: MoxieModel = .noop,
			 client: MoxieProvider) {
		self.input = input
		self.client = client
		
		if let data = UserDefaults.standard.data(forKey: "moxieModel"),
			 let decodedModel = try? CustomDecoderAndEncoder.decoder.decode(MoxieModel.self, from: data) {
			self.model = decodedModel
		} else {
			self.model = model
		}
		
		$input
			.sink { newValue in
			self.inputFID = Int(newValue) ?? 0
		}
		.store(in: &subscriptions)
		
		$inputFID
			.receive(on: DispatchQueue.main)
			.debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
			.sink { [weak self] value in
			guard let self = self, value != 0 else {
				return
			}
			Task {
				self.isLoading = true
				let result = try await client.fetchMoxieStats(userFID: self.inputFID)
				self.isLoading = false
				self.model = result
			}
		}
		.store(in: &subscriptions)
		
		$model
			.receive(on: DispatchQueue.main)
			.compactMap({ $0.moxieClaimTotals.first })
			.map({ $0.claimedAmount * self.price })
			.sink { [weak self] in
				self?.dollarValueMoxie = $0
				
			}
			.store(in: &subscriptions)
		
		$model
			.receive(on: DispatchQueue.main)
			.sink {
				let encoder = CustomDecoderAndEncoder.encoder
				
				let encodedData = try! encoder.encode($0)
					UserDefaults.standard.set(encodedData, forKey: "moxieModel")
			}
			.store(in: &subscriptions)
		
		$price
			.sink { [weak self] in
				self?.dollarValueMoxie = $0 * (self?.model.moxieClaimTotals.first?.claimedAmount ?? 0)
			}
			.store(in: &subscriptions)
	}
	
	func fetchPrice() async throws {
		price = try await client.fetchPrice()
	}
}

struct ContentView: View {
	@StateObject var viewModel: MoxieViewModel
		
	var body: some View {
			TabView {
				ZStack {
					Color.init(uiColor: MoxieColor.backgroundColor)
						.ignoresSafeArea(.all)
					VStack(alignment: .leading) {
						VStack {
							Text("Hello, \(viewModel.model.socials.first?.profileDisplayName ?? "Moxie")!")
								.font(.largeTitle)
								.scaledToFit()
								.fontDesign(.serif)
								.foregroundStyle(Color(uiColor: MoxieColor.dark))
								.fontWeight(.bold)
							
							TextField("Your Farcaster ID, e.g. 203666", text: $viewModel.input)
								.foregroundStyle(Color(uiColor: MoxieColor.textColor))
								.textFieldStyle(RoundedBorderTextFieldStyle())
								.fontDesign(.rounded)
								.padding(.vertical)
						}
						
						VStack(alignment: .leading) {
							Text("Claimed")
								.font(.title)
								.fontDesign(.serif)
								.foregroundStyle(Color(uiColor: MoxieColor.dark).blendMode(.luminosity))
								.fontWeight(.bold)
							
							Text("\(viewModel.model.moxieClaimTotals.first?.claimedAmount.formatted(.number.precision(.fractionLength(2))) ?? "0 $MOXIE") Ⓜ️")
								.font(.largeTitle)
								.fontDesign(.rounded)
								.foregroundStyle(Color(uiColor: MoxieColor.dark))
								.fontWeight(.heavy)
							Text("$\(viewModel.dollarValueMoxie.formatted(.number.precision(.fractionLength(2))))")
								.font(.body)
								.fontDesign(.rounded)
								.foregroundStyle(Color(uiColor: MoxieColor.dark))
								.fontWeight(.heavy)
						}
						.padding(.vertical)
						
						ScrollView {
							if !viewModel.isLoading {
								VStack(alignment: .leading) {
									if viewModel.inputFID == -1 {
										ContentUnavailableView {
											Label("No FID input", systemImage: "m.circle.fill")
												.foregroundStyle(Color(uiColor: MoxieColor.dark))
										} description: {
											Text("Try to search for another title.")
												.fontDesign(.rounded)
												.foregroundStyle(Color(uiColor: MoxieColor.textColor))
										}
									} else {
										VStack {
											CardView(imageSystemName: "text.bubble", title: "Cast earnings", amount: viewModel.model.castEarningsAmount.formatted(.number.precision(.fractionLength(2))))
											
											CardView(imageSystemName: "laptopcomputer", title: "Frame earnings", amount: viewModel.model.frameDevEarningsAmount.formatted(.number.precision(.fractionLength(2))))
											
											CardView(imageSystemName: "circle.circle", title: "All earnings", amount: viewModel.model.allEarningsAmount.formatted(.number.precision(.fractionLength(2))))
										}
									}
								}
							} else {
								ProgressView {
									Text("Fetching Moxie data...")
								}
							}
						}
						
						Spacer()
					}
					.padding()
					.redacted(reason: viewModel.isLoading ? .placeholder : [])
					.onAppear() {
						Task {
							try await viewModel.fetchPrice()
						}
					}
				}
				.tabItem {
					Label("Home", systemImage: "house.fill")
				}
				
				NavigationStack {
					ZStack {
						Color(uiColor: MoxieColor.backgroundColor)
							.ignoresSafeArea(.all)
						VStack {
							FCard(model: viewModel.model)
								.padding(.vertical)
							
							List {
								Section {
									NavigationLink("Schedule notifications") {
										ScheduleNotificationView()
									}
								} header: {
									Text("Notifications")
								} footer: {
									Text("Receive push notifications at scheduled intervals for daily and claimable $MOXIE.")
								}
							}
							.listStyle(GroupedListStyle())
							
							Spacer()
						}
						.navigationTitle("Settings")
					}
				}
				.tabItem {
					Label("Settings", systemImage: "gearshape")
				}
			}
			.tint(Color(uiColor: MoxieColor.dark))
		
	}
}

struct ScheduleNotificationView: View {
	@State private var moxieChangeText = ""
	@State private var isSheetPresented = false
	
	var body: some View {
		VStack(alignment: .leading) {
			ContentUnavailableView {
				Label("No scheduled notifications", systemImage: "bell.fill")
					.foregroundStyle(Color(uiColor: MoxieColor.dark))
			} description: {
				Text("Keep updated with your daily $MOXIE earnings")
					.fontDesign(.rounded)
					.foregroundStyle(Color(uiColor: MoxieColor.textColor))
			}
			
			Spacer()
			
		}
		.sheet(isPresented: $isSheetPresented, content: {
			Section {
				Text("Value in $MOXIE change")
					.font(.headline)
				TextField("Change value", text: $moxieChangeText, prompt: Text("e.g. 100"))
					.textFieldStyle(RoundedBorderTextFieldStyle())
			} footer: {
				Text("You will receive a notification every 100 $MOXIE you receive")
					.font(.caption)
			}
			.presentationDetents([.medium, .large])
			.presentationDragIndicator(.visible)
			.toolbar {
				ToolbarItem(placement: .bottomBar) {
					Button("Save") {
						print("Pressed")
					}
					.font(.headline)
					.foregroundStyle(Color(uiColor: MoxieColor.dark))
					.padding()
					.frame(maxWidth: .infinity)
					.background(Color(uiColor: MoxieColor.backgroundColor))
					.border(Color(uiColor: MoxieColor.dark), width: 2)
					
				}
			}
		})
		.toolbar {
			ToolbarItem(placement: .topBarTrailing) {
				Button(action: {
					isSheetPresented.toggle()
				}, label: {
					Image(systemName: "plus")
				})
			}
		}
		.toolbar(.hidden, for: .tabBar)
		.padding()
		.navigationTitle("Schedule notifications")
	}
}

struct CardView: View {
	let imageSystemName: String
	let title: String
	let amount: String
	
	var body: some View {
		HStack {
			Image(systemName: imageSystemName)
				.resizable()
				.renderingMode(.template)
				.aspectRatio(contentMode: .fit)
				.frame(width: 40)
				.padding(.trailing)
				.foregroundStyle(Color(uiColor: MoxieColor.otherColor))
			
			VStack(alignment: .leading) {
				Text(title)
					.font(.headline)
					.fontDesign(.rounded)
					.foregroundStyle(Color(uiColor: MoxieColor.otherColor))
					.fontWeight(.semibold)
				Text(amount)
					.font(.title2)
					.fontDesign(.rounded)
					.foregroundStyle(Color(uiColor: MoxieColor.otherColor).blendMode(.difference))
					.fontWeight(.medium)
			}

			Spacer()

			Menu {
				Text("This")
				Text("That")
			} label: {
				Image(systemName: "info.circle")
					.resizable()
					.aspectRatio(contentMode: .fit)
					.frame(width: 25)
					.padding(.trailing)
					.tint(Color(uiColor: MoxieColor.otherColor))
			}

		}
		.padding()
		.background(Color.init(uiColor: MoxieColor.dark))
	}
}

struct FCard: View {
	let model: MoxieModel?
	
	var body: some View {
		Group {
			if model != nil {
				HStack {
					AsyncImage(url: URL(string: model?.socials.first?.profileImage ?? ""),
										 content: { image in
						image
							.resizable()
							.aspectRatio(contentMode: .fit)
							.clipShape(Circle())
					}, placeholder: {
						ProgressView()
					})
					.frame(width: 100, height: 100)
					
					VStack(alignment: .leading) {
						Text("\(model?.socials.first?.profileDisplayName ?? "")")
							.font(.title2)
							.fontWeight(.bold)
						Text("\(model?.socials.first?.profileHandle ?? "")")
							.font(.body)
							.fontWeight(.medium)
							.opacity(0.8)
						Text(model?.entityID ?? "")
							.font(.caption)
							.fontWeight(.light)
					}
					
					Spacer()
				}
			} else {
				ContentUnavailableView("Not available", systemImage: "house.fill")
			 }
		}
		.padding()
		.background(Color(uiColor: MoxieColor.backgroundColor).blendMode(.screen))
		.background(Color(uiColor: MoxieColor.dark))
		.clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 10)))
		.padding()

	}
}

#Preview {
	ContentView(viewModel: .init(
		model: MoxieModel.placeholder,
		client: MockMoxieClient()))
}

#Preview {
	NavigationStack {
		ScheduleNotificationView()
	}
}
