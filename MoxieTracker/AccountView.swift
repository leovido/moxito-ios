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
			Image(option.imageName, bundle: .main)
				.resizable()
				.renderingMode(.original)
				.aspectRatio(contentMode: .fit)
				.padding(10)
				.foregroundColor(.white)
				.background(
					RoundedRectangle(cornerRadius: 10)
						.fill(Color(uiColor: MoxieColor.altGreen))
				)
				.frame(width: 40, height: 40)
				.padding(.trailing, 12)
			
			Text(option.name)
				.foregroundColor(.black)
				.fontWeight(.medium)
				.font(.custom("Inter", size: 16))
			
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
		ProfileOptions(name: "Profile", imageName: "profile"),
		ProfileOptions(name: "Settings", imageName: "settings"),
		ProfileOptions(name: "Help", imageName: "help"),
//		ProfileOptions(name: "Logout", imageName: "door")
	]
	
	let text = """
	Moxito is in BETA stage for testing! 🌱

	Get early access if you hold @leovido.eth's Fan Token

	You'll get a widget plus app that will show you your everyday rewards

	Soon you'll be able to claim from the app!
	"""
	
	@ViewBuilder
	private func destinationView(for option: ProfileOptions) -> some View {
		if option.name == "Help" {
			VStack {
				Link(destination: URL(string: "https://moxie.xyz")!) {
						HStack {
								Image(systemName: "link")
								Text("Moxie Website")
						}
						.padding()
						.background(Color(uiColor: MoxieColor.primary))
						.foregroundColor(.white)
						.cornerRadius(8)
				}
				Link(destination: URL(string: "https://warpcast.com/leovido.eth/0xe0424dd4")!) {
						HStack {
								Image(systemName: "link")
								Text("Widget instructions")
						}
						.padding()
						.background(Color(uiColor: MoxieColor.primary))
						.foregroundColor(.white)
						.cornerRadius(8)
				}
				
				Link(destination: URL(string: "https://moxiescout.xyz")!) {
						HStack {
								Image(systemName: "link")
								Text("Moxiescout by @zeni.eth")
						}
						.padding()
						.background(Color(uiColor: MoxieColor.primary))
						.foregroundColor(.white)
						.cornerRadius(8)
				}
				
				Link(destination: URL(string: "https://warpcast.com/~/compose?text=\(text) &embeds[]=https://moxito-allowlist.vercel.app/api")!) {
						HStack {
								Image(systemName: "link")
								Text("Share on Warpcast")
						}
						.padding()
						.background(Color(uiColor: MoxieColor.primary))
						.foregroundColor(.white)
						.cornerRadius(8)
				}
				
				Spacer()
			}
			.navigationTitle("Help")
		} else if option.name == "Settings" {
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
