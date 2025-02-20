import SwiftUI
import MoxieLib

struct EarningsCardsView: View {
	@EnvironmentObject var viewModel: MoxieViewModel
	
	var body: some View {
		VStack {
			if viewModel.inputFID == -1 {
				ContentUnavailableView {
					Label("No FID input", systemImage: "m.circe.fill")
						.foregroundStyle(Color(uiColor: MoxieColor.dark))
				} description: {
					Text("Try to search for another title.")
						.fontDesign(.rounded)
						.foregroundStyle(Color(uiColor: MoxieColor.textColor))
				}
			} else {
				CardView(imageSystemName: "square.grid.2x2.fill",
								 title: "Cast earnings",
								 amount: viewModel.model.castEarningsAmount,
								 price: viewModel.price,
								 info: "Earnings from casts. Likes, recasts/quoteCasts and replies all earn you $MOXIE")
				
				CardView(imageSystemName: "rectangle.grid.1x2.fill",
								 title: "Frame earnings",
								 amount: viewModel.model.frameDevEarningsAmount,
								 price: viewModel.price,
								 info: "Earnings from frames that you build when you use Airstack frame validator")
				
				CardView(imageSystemName: "circle.hexagongrid.fill",
								 title: "All earnings",
								 amount: viewModel.model.allEarningsAmount,
								 price: viewModel.price,
								 info: "All earnings from casts and frames")
			}
		}
	}
}
