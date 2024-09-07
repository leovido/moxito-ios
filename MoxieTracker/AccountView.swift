import SwiftUI
import MoxieLib

struct ProfileOptions: Hashable, Identifiable {
	let id: UUID
	let name: String
	let imageName: String
	
	init(id: UUID = .init(), name: String, imageName: String) {
		self.id = id
		self.name = name
		self.imageName = imageName
	}
}

struct AccountView: View {
	@ObservedObject var viewModel: MoxieViewModel
	
	let profileOptions: [ProfileOptions] = [
		.init(name: "My account", imageName: "person"),
		.init(name: "Settings", imageName: "gearshape.fill"),
		.init(name: "Help", imageName: "questionmark.circle.fill")
	]
	
	var body: some View {
		NavigationStack {
			ZStack {
				Color(uiColor: MoxieColor.primary)
					.ignoresSafeArea()
				VStack(alignment: .leading) {
					ProfileCardView(model: viewModel.model)
					
					ScrollView {
						ForEach(profileOptions, id: \.self) { option in
							NavigationLink(value: option) {
								HStack {
									VStack {
										Image(systemName: option.imageName)
											.resizable()
											.renderingMode(.template)
											.aspectRatio(contentMode: .fit)
											.padding(10)
											.foregroundColor(.white)
											.background(
												RoundedRectangle(cornerRadius: 10)
													.fill(Color(uiColor: MoxieColor.green))
											)
									}
									.frame(width: 40, height: 40)
									.padding(.trailing, 12)
									
									Text(option.name)
										.foregroundStyle(Color.black)
										.fontWeight(.medium)
									
									Spacer()
									
									Image(systemName: "chevron.right")
										.padding(.trailing, 30)

								}
							}
							.padding([.top, .leading], 32)
						}
						.navigationDestination(for: ProfileOptions.self) { option in
							Text(option.name)
						}
					}
					.background(Color.white)
					.clipShape(UnevenRoundedRectangle(topLeadingRadius: 32, topTrailingRadius: 32))
						Spacer()
					}
					.navigationTitle("Profile")
				}
			}
			.tabItem {
				Label("Profile", systemImage: "person")
			}
		}
	}
	
	#Preview {
		AccountView(viewModel: .init(client: MockMoxieClient()))
	}
