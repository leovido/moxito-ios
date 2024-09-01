import SwiftUI
import MoxieLib

struct ProfileCardView: View {
	let model: MoxieModel?
	
	var body: some View {
		Group {
			if model != nil {
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
					.frame(width: 100, height: 100)
					
					VStack(alignment: .leading) {
						Text("\(model?.socials.first?.profileDisplayName ?? "")")
							.font(.title2)
							.fontWeight(.bold)
							.foregroundStyle(Color(uiColor: MoxieColor.otherColor))
						Text("\(model?.socials.first?.profileHandle ?? "")")
							.font(.body)
							.fontWeight(.medium)
							.opacity(0.8)
							.foregroundStyle(Color(uiColor: MoxieColor.otherColor))

						Text(model?.entityID ?? "")
							.font(.caption)
							.fontWeight(.light)
							.foregroundStyle(Color(uiColor: MoxieColor.otherColor))
					}
					
					Spacer()
				}
			} else {
				ContentUnavailableView("Sign in with your FC account", systemImage: "key.horizontal")
			}
		}
		.padding()
		.background(Color(uiColor: MoxieColor.dark))
		.clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 10)))
		.padding()
	}
}


#Preview {
	ProfileCardView(model: .placeholder)
		.fixedSize()
}
