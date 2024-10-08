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
		.padding([.top], 12)
	}
}

struct AccountView: View {
	@EnvironmentObject var viewModel: MoxieViewModel

	@State private var profileOptions: [ProfileOptions] = [
		ProfileOptions(name: "Settings", imageName: "settings"),
		ProfileOptions(name: "Help", imageName: "help")
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

				Section(content: {
					HStack(spacing: 5) {
						WidgetHarios()
						MoxieSimpleWidget()
					}
					.frame(height: 200)
				}, header: {
						Text("Widgets")
						.multilineTextAlignment(.leading)
						.font(.custom("Inter", size: 28))
						.bold()
					})

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
				Spacer()
			}
			.navigationTitle("Help")
		} else if option.name == "Settings" {
			SettingsView(viewModel: viewModel)
				.toolbar(.hidden, for: .tabBar)

		} else if option.name == "Profile" {
			ProfileView()
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

struct MoxieSimpleWidget: View {
	@EnvironmentObject var viewModel: MoxieViewModel

	var dollarValueDaily: String {
		let d = viewModel.price * viewModel.model.allEarningsAmount
		return formattedDollarValue(dollarValue: d)
	}

	var dollarValueClaimable: String {
		let d = viewModel.model.moxieClaimTotals[0].availableClaimAmount * viewModel.price
		return formattedDollarValue(dollarValue: d)
	}

	var body: some View {
		VStack(alignment: .leading) {
			HStack {
				VStack(alignment: .leading, spacing: 0) {
					HStack {
						Text("Daily")
							.foregroundStyle(Color(uiColor: MoxieColor.textColor))
							.fontDesign(.rounded)
							.fontWeight(.black)

						Image("CoinMoxiePurple", bundle: .main)
							.resizable()
							.aspectRatio(contentMode: .fit)
							.frame(width: 15)
					}
					.padding(.bottom, -6)

					Text(viewModel.model.allEarningsAmount.formatted(.number.precision(.fractionLength(0))))
						.foregroundStyle(Color(uiColor: MoxieColor.dark))
						.fontWeight(.heavy)
						.fontDesign(.rounded)

					Text("~\(dollarValueDaily)")
						.foregroundStyle(Color(uiColor: MoxieColor.dark))
						.font(.caption)
						.fontWeight(.light)
						.fontDesign(.rounded)
						.padding(.bottom, 4)

					HStack {
						Text("Claimable")
							.foregroundStyle(Color(uiColor: MoxieColor.textColor))
							.fontDesign(.rounded)
							.fontWeight(.black)

						Image("CoinMoxiePurple", bundle: .main)
							.resizable()
							.aspectRatio(contentMode: .fit)
							.frame(width: 15)
					}
					.padding(.bottom, -6)

					Text(viewModel.model.moxieClaimTotals[0].availableClaimAmount.formatted(.number.precision(.fractionLength(0))))
						.foregroundStyle(Color(uiColor: MoxieColor.dark))
						.fontWeight(.heavy)
						.fontDesign(.rounded)
					Text("~\(dollarValueClaimable)")
						.foregroundStyle(Color(uiColor: MoxieColor.dark))
						.font(.caption)
						.fontWeight(.light)
						.fontDesign(.rounded)

					Spacer()
				}

			}
		}
		.padding(.top, 8)
		.padding(.leading, -8)
		.frame(width: 155, height: 155, alignment: .center)
		.background(Color(uiColor: MoxieColor.backgroundColor))
		.clipShape(RoundedRectangle.init(cornerRadius: 20))
	}
}

struct WidgetHarios: View {
	@EnvironmentObject var viewModel: MoxieViewModel

	var body: some View {
		ZStack {
			Image("MoxitoBG", bundle: .main)
			VStack {
				MiniCard(title: "Daily:",
								 moxieValue: viewModel.model.allEarningsAmount,
								 moxieUSD: viewModel.model.allEarningsAmount * viewModel.price)
				.padding(.top)
				MiniCard(title: "Claimable:",
								 moxieValue: viewModel.model.moxieClaimTotals[0].availableClaimAmount,
								 moxieUSD: viewModel.model.moxieClaimTotals[0].availableClaimAmount * viewModel.price)
			}
		}
	}
}

struct MiniCard: View {
	let title: String
	let moxieValue: Decimal
	let moxieUSD: Decimal

	var dollarValue: String {
		formattedDollarValue(dollarValue: moxieUSD)
	}

	init(title: String, moxieValue: Decimal, moxieUSD: Decimal) {
		self.title = title
		self.moxieValue = moxieValue
		self.moxieUSD = moxieUSD
	}

	var body: some View {
		HStack {
			Image("CoinMoxie", bundle: .main)
				.resizable()
				.aspectRatio(contentMode: .fit)
				.frame(height: 30)
				.padding(.trailing, -4)
				.padding(.leading, 4)

			VStack(alignment: .leading) {
				Text("\(title)")
					.fontWeight(.bold)
					.font(.custom("Inter", size: 10))
					.foregroundStyle(Color.white)
					.padding(.top, 4)

				Text(moxieValue.formatted(.number.precision(.fractionLength(0))))
						.font(.custom("Inter", size: 15))
						.textScale(.secondary)
						.foregroundStyle(Color.white)
						.fontWeight(.bold)

				Text("~\(dollarValue)")

					.font(.custom("Inter", size: 10))
					.fontDesign(.rounded)
					.foregroundStyle(Color.white)
					.fontWeight(.light)
					.padding(.bottom, 4)
			}
			.padding(.vertical, 2)

			Spacer()
		}
		.frame(width: 140)
		.background(Color(uiColor: MoxieColor.primary))
		.clipShape(RoundedRectangle(cornerSize: CGSize(width: 8, height: 8)))
	}
}

#Preview {
	AccountView()
		.environmentObject(MoxieViewModel())
}
