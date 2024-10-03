import SwiftUI
import MoxieLib

struct ProfileCardView: View {
	let model: MoxieModel?

	var body: some View {
		VStack {
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
				.frame(width: 80, height: 80)
				.padding(.leading)

				VStack(alignment: .leading) {
					Text("\(model?.socials.first?.profileDisplayName ?? "")")
						.font(.body)
						.fontWeight(.medium)
						.foregroundStyle(Color.white)
						.font(.custom("Inter", size: 16))

					Text("@\(model?.socials.first?.profileHandle ?? "")")
						.font(.caption)
						.fontWeight(.light)
						.opacity(0.8)
						.foregroundStyle(Color.white)
						.font(.custom("Inter", size: 16))

					Text("FID: \(model?.entityID ?? "")")
						.font(.caption)
						.fontWeight(.light)
						.foregroundStyle(Color.white)
						.font(.custom("Inter", size: 16))

				}
			}
		}
	}
}

struct ProfileCardAlternativeView: View {
	let model: MoxieModel?
	let rank: Decimal

	var body: some View {
		VStack(spacing: 0) {
			ZStack {
				AsyncImage(url: URL(string: model?.socials.first?.profileImage ?? ""),
									 content: { image in
					image
						.resizable()
						.aspectRatio(contentMode: .fill)
						.clipShape(Circle())
				}, placeholder: {
					ProgressView()
				})
				.frame(width: 80, height: 80)

				VStack {
					Text(rank.description)
						.font(.custom("Inter", size: 15))
						.fontWeight(.bold)

					Text("Rank")
						.font(.custom("Inter", size: 9))
						.fontWeight(.light)
				}
				.frame(width: 35, height: 35)
				.background(
					RoundedRectangle(cornerRadius: 10)
						.fill(Color.moxieBlue)
				)
				.padding(.leading, 60)
				.padding(.bottom, 80)
			}

			VStack {
				Text("@\(model?.socials.first?.profileHandle ?? "")")
					.font(.custom("Inter", size: 16))
					.foregroundStyle(Color.white)
					.bold()

				Text("FID: \(model?.entityID ?? "")")
					.fontWeight(.light)
					.foregroundStyle(Color.white)
					.font(.custom("Inter", size: 12))
			}
			.padding(.bottom, 16)
		}
	}
}

#Preview {
	ProfileCardAlternativeView(model: .placeholder, rank: 1)
		.background(Color(uiColor: MoxieColor.primary))
}
