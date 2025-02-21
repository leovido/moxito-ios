import SwiftUI
import MoxieLib

struct VotingInfoView: View {
	var body: some View {
		VStack(alignment: .leading) {
			Text("Moxie Retro1 Grant voting is now open!")
				.font(.body)
				.font(.custom("Inter", size: 18))
				.foregroundColor(Color.white)
				.padding()

			Text("If you like the Moxito, please consider voting for 6. ds8 — He is splitting his winnings 1:1 with Moxito + Moxie Browser extension.")
				.font(.body)
				.font(.custom("Inter", size: 15))
				.foregroundColor(Color.white)
				.padding([.leading, .bottom, .trailing])

			Text("Voting closes on the 7th!")
				.font(.caption)
				.font(.custom("Inter", size: 13))
				.foregroundColor(Color.white)
				.padding([.leading, .bottom])

			Link(destination: URL(string: "https://snapshot.box/#/s:moxie.eth/proposal/0x82a8b1b8a2bd77d3b706b8cd0c80d1d12947a63cd20630e44d44f960e67be5a4")!, label: {
				Text("Go vote!")
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
