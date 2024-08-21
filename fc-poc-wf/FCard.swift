import SwiftUI
import TipLibs

struct FCard: View {
	let model: TipModel?
	let willRedact: RedactionReasons
	
	init(model: TipModel?, willRedact: RedactionReasons) {
		self.model = model
		self.willRedact = willRedact
	}
	
	var body: some View {
		HStack {
			AsyncImage(url: URL(string: model?.pfpUrl ?? ""),
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
				Text("\(model?.displayName ?? "")")
					.font(.title2)
					.fontWeight(.bold)
				Text("@\(model?.username ?? "")")
					.font(.body)
					.fontWeight(.medium)
					.opacity(0.8)
				Text("\(model?.fid ?? 0)")
					.font(.caption)
					.fontWeight(.light)
			}
			
			Spacer()
			
			Text("#21")
				.font(.largeTitle)
				.fontWeight(.heavy)
			
		}
		.padding()
		.background(FartherTheme.backgroundColor.blendMode(.screen))
		.background(FartherTheme.backgroundColor)
		.clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 10)))
		.foregroundStyle(FartherTheme.foregroundColor)
		.redacted(reason: willRedact)
	}
}


#Preview {
	List {
		FCard(model: .placeholder, willRedact: [])
		FCard(model: .placeholder, willRedact: [])
		FCard(model: .placeholder, willRedact: [])
		FCard(model: .placeholder, willRedact: [])
		FCard(model: .placeholder, willRedact: [])
	}
	.listStyle(PlainListStyle())
}
