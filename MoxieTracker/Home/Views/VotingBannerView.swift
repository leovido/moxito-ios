import SwiftUI

struct VotingBannerView: View {
    let title: String
    let description: String
    let deadline: String
    let buttonText: String
    let voteUrl: URL
    let expirationDate: Date

    init(
        title: String = "Moxie Retro1 Grant voting is now open!",
        description: String = "If you like the Moxito, please consider voting for 6. ds8 — He is splitting his winnings 1:1 with Moxito + Moxie Browser extension.",
        deadline: String = "Voting closes on the 7th!",
        buttonText: String = "Go vote!",
        voteUrl: URL = URL(string: "https://snapshot.box/#/s:moxie.eth/proposal/0x82a8b1b8a2bd77d3b706b8cd0c80d1d12947a63cd20630e44d44f960e67be5a4")!,
        expirationDate: Date = Calendar.current.date(from: DateComponents(year: 2024, month: 11, day: 7)) ?? Date()
    ) {
        self.title = title
        self.description = description
        self.deadline = deadline
        self.buttonText = buttonText
        self.voteUrl = voteUrl
        self.expirationDate = expirationDate
    }

    var body: some View {
        if Date() < expirationDate {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.body)
                    .font(.custom("Inter", size: 18))
                    .foregroundColor(Color.white)
                    .padding()

                Text(description)
                    .font(.body)
                    .font(.custom("Inter", size: 15))
                    .foregroundColor(Color.white)
                    .padding([.leading, .bottom, .trailing])

                Text(deadline)
                    .font(.caption)
                    .font(.custom("Inter", size: 13))
                    .foregroundColor(Color.white)
                    .padding([.leading, .bottom])

                Link(destination: voteUrl, label: {
                    Text(buttonText)
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
}

// MARK: - Preview
#Preview {
    VotingBannerView()
}
