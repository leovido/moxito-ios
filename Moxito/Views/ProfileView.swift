import SwiftUI
import MoxieLib

struct ProfileView: View {
	let columns = [
		GridItem(.flexible()),
		GridItem(.flexible(minimum: 100, maximum: 200))
	]

	@EnvironmentObject var viewModel: MoxieViewModel

	var tvlText: String {
		guard let fcScore = viewModel.model.socials.farcasterScore else {
			return ""
		}
		let decimal = Decimal(string: fcScore.tvl) ?? 0
		let value = decimal / pow(10, 18)

		return value.formatted(.number.precision(.fractionLength(2)))
	}

	var farScore: String {
		guard let fcScore = viewModel.model.socials.farcasterScore?.farScore else {
			return ""
		}
		return fcScore.formatted(.number.precision(.fractionLength(2)))
	}

	var body: some View {
		NavigationStack {
			ZStack {
				Color(uiColor: MoxieColor.primary)
					.ignoresSafeArea(.all)
				VStack {
					ProfileCardAlternativeView(model: viewModel.model, rank: viewModel.model.socials.farcasterScore?.farRank ?? 0)

					ScrollView {
						LazyVGrid(columns: columns, spacing: 16) {
							VStack {
								GridItemView(title: "Moxie", value: viewModel.fansCount, subtitle: "Fans", icon: "person.2.fill")
								GridItemView(title: "Farscore", value: farScore, subtitle: "", icon: "chart.bar.fill")
								GridItemView(title: "TVL", value: tvlText, subtitle: "Staked", icon: "lock.fill")
//								GridItemView(title: "TVL", value: "-", subtitle: "Unstaked", icon: "lock.open.fill")

							}

							VStack {
								GridItemBigView(farScore: viewModel.model.socials.farcasterScore?.farScore ?? 0)

								Spacer()
							}

						}
						.padding()

						Link(destination: URL(string: "farcaster://home")!, label: {
							Label(title: {
								Text("Open Warpcast")

							}, icon: {
								Image("fc-logo", bundle: .main)
									.resizable()
									.aspectRatio(contentMode: .fit)
									.foregroundStyle(Color.white)
									.frame(width: 20, height: 20)
							})
							.padding()
							.frame(maxWidth: .infinity)
							.background(Color(uiColor: MoxieColor.farcasterPurple))
							.clipShape(Capsule())
							.fontWeight(.bold)
							.foregroundStyle(Color.white)
							.font(.custom("Inter", size: 16))
							.padding(.horizontal)
						})
					}
					.background(Color.white)
					.clipShape(UnevenRoundedRectangle(topLeadingRadius: 32, topTrailingRadius: 32))
				}
			}
		}
	}
}

struct GridItemView: View {
	let title: String
	let value: String
	let subtitle: String
	let icon: String

	var body: some View {
		VStack {
			VStack(alignment: .leading, spacing: 4) {
				HStack {
					Text(title)
						.scaledToFit()
						.foregroundColor(Color(uiColor: MoxieColor.primary))
						.bold()
						.scaledFont(name: "Inter", size: 18)

					Spacer()

					Image(systemName: icon)
						.foregroundColor(Color(uiColor: MoxieColor.primary))
				}

				HStack {
					Text(value)
						.scaledToFit()
						.fontWeight(.bold)
						.foregroundColor(.black)
						.scaledFont(name: "Inter", size: 21)
						.minimumScaleFactor(0.8)
				}

				if !subtitle.isEmpty {
					Text(subtitle)
						.font(.footnote)
						.foregroundColor(.gray)
				}
			}
			.padding()
			.background(RoundedRectangle(cornerRadius: 16)
				.stroke(Color.gray.opacity(0.2), lineWidth: 1))
			.background(Color.white)

			Spacer()
		}
	}
}

struct GridItemBigView: View {
	let farScore: Decimal

	var like: String {
		let decimal = farScore * 0.5

		return decimal.formatted(.number.precision(.fractionLength(0)))
	}

	var reply: String {
		let decimal = farScore * 1

		return decimal.formatted(.number.precision(.fractionLength(0)))
	}

	var recast: String {
		let decimal = farScore * 2

		return decimal.formatted(.number.precision(.fractionLength(0)))
	}

	var replyke: String {
		let decimal = farScore * 3.5

		return decimal.formatted(.number.precision(.fractionLength(0)))
	}

	var body: some View {
		VStack(alignment: .leading, spacing: 11) {
			ProfileSectionMoxieStatView(moxieStat: .init(title: "Like",
																									 value: like,
																									 icon: "heart.fill"))

			ProfileSectionMoxieStatView(moxieStat: .init(title: "Reply",
																									 value: reply,
																									 icon: "text.bubble.fill"))

			ProfileSectionMoxieStatView(moxieStat: .init(title: "Recast",
																									 value: recast,
																									 icon: "arrowshape.turn.up.backward.fill"))

			ProfileSectionMoxieStatView(moxieStat: .init(title: "Replyke",
																									 value: replyke,
																									 icon: "square.stack.fill"))

//			Spacer()
		}
		.padding()
		.background(RoundedRectangle(cornerRadius: 16)
			.stroke(Color.gray.opacity(0.2), lineWidth: 1))
		.background(Color.white)
	}
}

#Preview {
	NavigationStack {
		ProfileView()
			.environmentObject(MoxieViewModel(model: .placeholder))
	}
}
