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

struct ProfileOptionRow: View {
	var option: ProfileOptions
	
	var body: some View {
		HStack {
			Image(systemName: option.imageName)
				.resizable()
				.aspectRatio(contentMode: .fit)
				.padding(10)
				.foregroundColor(.white)
				.background(
					RoundedRectangle(cornerRadius: 10)
						.fill(Color(uiColor: MoxieColor.green))
				)
				.frame(width: 40, height: 40)
				.padding(.trailing, 12)
			
			Text(option.name)
				.foregroundColor(.black)
				.fontWeight(.medium)
			
			Spacer()
			
			Image(systemName: "chevron.right")
				.padding(.trailing, 30)
				.foregroundColor(.gray)
		}
		.padding([.top, .leading], 12)
	}
}

struct AccountView: View {
	@ObservedObject var viewModel: MoxieViewModel
	
	@State private var profileOptions: [ProfileOptions] = [
		ProfileOptions(name: "Profile", imageName: "person.circle"),
		ProfileOptions(name: "Settings", imageName: "gearshape"),
		ProfileOptions(name: "Help", imageName: "questionmark.circle.fill")
		// Add more options here...
	]
	
	@ViewBuilder
	private func destinationView(for option: ProfileOptions) -> some View {
		if option.name == "Settings" {
			SettingsView(viewModel: viewModel)
				.toolbar(.hidden, for: .tabBar)

		} else {
			Text(option.name)
		}
	}
	
	var body: some View {
		NavigationStack {
			ZStack {
				Color(uiColor: MoxieColor.primary)
					.ignoresSafeArea()
				VStack(alignment: .leading) {
					ProfileCardView(model: viewModel.model)
					
					ScrollView {
						ForEach(profileOptions, id: \.self) { option in
							NavigationLink(destination: destinationView(for: option)) {
								ProfileOptionRow(option: option)
							}
							.padding([.top, .leading], 16)
						}
					}
					.background(Color.white)
					.clipShape(UnevenRoundedRectangle(topLeadingRadius: 32, topTrailingRadius: 32))
					Spacer()
				}
			}
		}
		.tabItem {
			Image(systemName: "person")
		}
	}
}

#Preview {
	AccountView(viewModel: .init(client: MockMoxieClient()))
}
