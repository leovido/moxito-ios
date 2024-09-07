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
				.frame(width: 100, height: 100)
				
				VStack(alignment: .leading) {
					Text("\(model?.socials.first?.profileDisplayName ?? "")")
						.font(.body)
						.fontWeight(.medium)
						.foregroundStyle(Color.white)
					Text("@\(model?.socials.first?.profileHandle ?? "")")
						.font(.caption)
						.fontWeight(.light)
						.opacity(0.8)
						.foregroundStyle(Color.white)
					Text("FID: \(model?.entityID ?? "")")
						.font(.caption)
						.fontWeight(.light)
						.foregroundStyle(Color.white)
				}
			}
		}
	}
}


#Preview {
	ProfileCardView(model: .placeholder)
		.fixedSize()
}
