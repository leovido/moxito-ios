import SwiftUI
import MoxieLib

struct VotingInfoView: View {
	var body: some View {
		VStack(alignment: .leading) {
			Text("Moxito announcements")
				.font(.headline)
				.font(.custom("Inter", size: 18))
				.foregroundColor(Color.white)
				.padding()

			Text("Announcements will be posted here! Moxito is a web3 and fitness/health app that allows you to earn rewards for your activity and more.")
				.font(.body)
				.font(.custom("Inter", size: 15))
				.foregroundColor(Color.white)
				.padding([.leading, .bottom, .trailing])

			Text("Find out more on Warpcast:")
				.font(.caption)
				.font(.custom("Inter", size: 13))
				.foregroundColor(Color.white)
				.padding([.leading, .bottom])

			Link(destination: URL(string: "https://warpcast.com/moxito")!, label: {
				Text("Visit channel!")
					.foregroundStyle(Color.white)
					.padding(.horizontal)
			})
			.padding(8)
			.background(Color(uiColor: MoxieColor.green))
			.clipShape(RoundedRectangle(cornerRadius: 24))
			.padding([.leading, .bottom])
		}
		.padding(6)
		.background(Color(uiColor: MoxieColor.primary))
		.clipShape(RoundedRectangle(cornerRadius: 14))
	}
}
