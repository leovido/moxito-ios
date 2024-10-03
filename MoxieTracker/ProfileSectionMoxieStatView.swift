import SwiftUI
import MoxieLib

enum MoxieStat {
	case like
	case reply
	case recast
	case replyke
}

struct ProfileMoxieStat {
	let title: String
	let value: String
	let icon: String
}

struct ProfileSectionMoxieStatView: View {
	let moxieStat: ProfileMoxieStat

	var body: some View {
		VStack(spacing: 4) {
			HStack {
				Text(moxieStat.title)
					.foregroundColor(Color(uiColor: MoxieColor.primary))
					.bold()
					.scaledFont(name: "Inter", size: 18)

				Spacer()

				Image(systemName: moxieStat.icon)
					.resizable()
					.aspectRatio(contentMode: .fit)
					.frame(width: 24, height: 24)
					.foregroundColor(Color(uiColor: MoxieColor.primary))

			}
			HStack {
				Text(moxieStat.value)
					.fontWeight(.bold)
					.foregroundColor(.black)
					.scaledFont(name: "Inter", size: 21)

				Image("CoinMoxiePurple", bundle: .main)
					.resizable()
					.aspectRatio(contentMode: .fit)
					.frame(width: 15, height: 15)

				Spacer()
			}
		}
		.padding(.bottom, 15)
	}
}

#Preview {
	VStack {
		ProfileSectionMoxieStatView(moxieStat: .init(title: "Like", value: "3124", icon: "heart.fill"))
			.background(Color.yellow)
		ProfileSectionMoxieStatView(moxieStat: .init(title: "Like", value: "3124", icon: "heart.fill"))
	}
}
