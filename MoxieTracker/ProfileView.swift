import SwiftUI
import MoxieLib

struct ProfileView: View {
	let columns = [
		GridItem(.flexible()),
		GridItem(.flexible())
	]

	@EnvironmentObject var viewModel: MoxieViewModel

	var body: some View {
		ZStack {
			Color(uiColor: MoxieColor.primary)
				.ignoresSafeArea(.all)
			VStack {
//				ProfileCardAlternativeView(model: viewModel.model, rank: viewModel.model.socials.first?.farcasterScore?.farRank ?? 0)
				LazyVGrid(columns: columns, spacing: 16) {
					GridItemView(title: "Moxie", value: "49", subtitle: "Fans", icon: "person.2.fill")

					GridItemView(title: "Like", value: "22.50 M", subtitle: "", icon: "heart.fill")

					GridItemBigView(farScore: 3423.43, icon: "heart")

					GridItemView(title: "TVL", value: "$100.5 k", subtitle: "$Moxie token", icon: "lock.fill")

					GridItemView(title: "Recast", value: "22.50 M", subtitle: "", icon: "arrowshape.turn.up.right.fill")

					GridItemView(title: "Replying", value: "22.50 M", subtitle: "", icon: "message.fill")
				}
				.padding()
				//				ScrollView {
				//					VStack(alignment: .leading) {
				//						HStack {
				//							Text("Moxie")
				//								.font(.custom("Inter", size: 14))
				//								.bold()
				//								.foregroundStyle(Color(uiColor: MoxieColor.primary))
				//
				//							Image(systemName: "person.fill")
				//								.resizable()
				//								.aspectRatio(contentMode: .fit)
				//								.frame(width: 20)
				//								.foregroundStyle(Color(uiColor: MoxieColor.primary))
				//						}
				//						Text("\(viewModel.model.socials.first?.farcasterScore?.farRank ?? 0)")
				//
				//						Text("Fans")
				//							.font(.custom("Inter", size: 14))
				//							.foregroundStyle(Color.gray)
				//					}
				//					.padding()
				//					.overlay(
				//						RoundedRectangle(cornerRadius: 24)
				//							.stroke(.gray, lineWidth: 1)
				//					)
				//
				//					VStack(alignment: .leading) {
				//						HStack {
				//							Text("Like/Farscore")
				//								.font(.custom("Inter", size: 14))
				//								.bold()
				//								.foregroundStyle(Color(uiColor: MoxieColor.primary))
				//
				//							Spacer()
				//
				//							Image(systemName: "person.fill")
				//								.resizable()
				//								.aspectRatio(contentMode: .fit)
				//								.frame(width: 20)
				//								.foregroundStyle(Color(uiColor: MoxieColor.primary))
				//						}
				//						Text("\(viewModel.model.socials.first?.farcasterScore?.farScore ?? 0)")
				//					}
				//					.padding()
				//					.overlay(
				//						RoundedRectangle(cornerRadius: 24)
				//							.stroke(.gray, lineWidth: 1)
				//					)
				//
				//					Text("Far Score")
				//						.font(.custom("Inter", size: 14))
				//						.bold()
				//						.foregroundStyle(Color(uiColor: MoxieColor.primary))
				//					Text("\(viewModel.model.socials.first?.farcasterScore?.farScore ?? 0)")
				//					Text("Liquidity")
				//						.font(.custom("Inter", size: 14))
				//						.bold()
				//						.foregroundStyle(Color(uiColor: MoxieColor.primary))
				//					Text("\(viewModel.model.socials.first?.farcasterScore?.liquidityBoost ?? 0)")
				//					Text("TVL")
				//						.font(.custom("Inter", size: 14))
				//						.bold()
				//						.foregroundStyle(Color(uiColor: MoxieColor.primary))
				//					Text(viewModel.model.socials.first?.farcasterScore?.tvl ?? "0")
				//				}
				//				.background(Color.white)
				//				.clipShape(UnevenRoundedRectangle(topLeadingRadius: 32, topTrailingRadius: 32))
				//				}
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
		VStack(alignment: .leading, spacing: 4) {
			HStack {
				Text(title)
					.font(.headline)
					.foregroundColor(Color.purple)

				Spacer()

				Image(systemName: icon)
					.foregroundColor(Color.purple)
			}
			HStack {
				Text(value)
					.font(.title)
					.fontWeight(.bold)
					.foregroundColor(.black)

				Image("CoinMoxiePurple", bundle: .main)
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
		.background(Color.white) // Optional: to match the card look in your design
	}
}

struct GridItemBigView: View {
	let farScore: Decimal
	let icon: String

	var like: String {
		farScore.formatted(.number.precision(.fractionLength(0)))
	}

	var reply: String {
		let d = farScore * 3

		return d.formatted(.number.precision(.fractionLength(0)))
	}

	var recast: String {
		let d = farScore * 6

		return d.formatted(.number.precision(.fractionLength(0)))
	}

	var replyke: String {
		let d = farScore * 10

		return d.formatted(.number.precision(.fractionLength(0)))
	}

	var body: some View {
		VStack(alignment: .leading, spacing: 4) {
			VStack {
				HStack {
					Text("Like/Farscore")
						.foregroundColor(Color(uiColor: MoxieColor.primary))
						.bold()
						.font(.custom("Inter", size: 14))

					Spacer()

					Image(systemName: icon)
						.foregroundColor(Color(uiColor: MoxieColor.primary))
				}
				HStack {
					Text(like)
						.fontWeight(.bold)
						.foregroundColor(.black)
						.font(.custom("Inter", size: 18))

					Image("CoinMoxiePurple", bundle: .main)
				}
			}

			VStack {
				HStack {
					Text("Reply")
						.font(.headline)
						.foregroundColor(Color.purple)

					Spacer()

					Image(systemName: icon)
						.foregroundColor(Color.purple)
				}
				HStack {
					Text(reply)
						.font(.title)
						.fontWeight(.bold)
						.foregroundColor(.black)

					Image("CoinMoxiePurple", bundle: .main)
				}
			}

			VStack {
				HStack {
					Text("Recast")
						.font(.headline)
						.foregroundColor(Color.purple)

					Spacer()

					Image(systemName: icon)
						.foregroundColor(Color.purple)
				}
				HStack {
					Text(recast)
						.font(.title)
						.fontWeight(.bold)
						.foregroundColor(.black)

					Image("CoinMoxiePurple", bundle: .main)
				}
			}

			VStack {
				HStack {
					Text("REPLYKE")
						.font(.headline)
						.foregroundColor(Color.purple)

					Spacer()

					Image(systemName: icon)
						.foregroundColor(Color.purple)
				}
				HStack {
					Text(replyke)
						.font(.title)
						.fontWeight(.bold)
						.foregroundColor(.black)

					Image("CoinMoxiePurple", bundle: .main)
				}
			}
		}
		.padding()
		.background(RoundedRectangle(cornerRadius: 16)
			.stroke(Color.gray.opacity(0.2), lineWidth: 1))
		.background(Color.white) // Optional: to match the card look in your design
	}
}

#Preview {
	ProfileView()
		.environmentObject(MoxieViewModel(model: .placeholder))
}
