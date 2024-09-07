import SwiftUI
import MoxieLib

struct CardView: View {
	@Environment(\.locale) var locale

	let imageSystemName: String
	let title: String
	let amount: String
	let price: Decimal
	let info: String
	
	var dollarValue: Decimal {
		do {
			let am = try Decimal(amount,
									format: .currency(code: locale.currency?.identifier ?? "USD"))
			
			return price * am

		} catch {
			dump(error)
		}
		
		return 0
	}
	
	var body: some View {
		HStack {
			VStack {
				Image(systemName: imageSystemName)
					.resizable()
					.renderingMode(.template) // Use .template to apply the foreground color
					.aspectRatio(contentMode: .fit)
					.padding(10)
					.foregroundColor(.white) // Set the SF Symbol color to white
					.background(
						RoundedRectangle(cornerRadius: 10)
							.fill(Color(uiColor: MoxieColor.green)) // Green background with rounded corners
					)
			}
			.frame(width: 40, height: 40)
			.padding(.leading)
			.padding(.trailing, 12)
			
			VStack(alignment: .leading, spacing: 0) {
				Text(title)
					.font(.headline)
					.fontDesign(.rounded)
					.foregroundStyle(Color.white)
				
				HStack(spacing: 1) {
					Text(amount)
						.font(.title)
						.fontDesign(.rounded)
						.foregroundStyle(Color.white)
						.fontWeight(.heavy)
						.padding(.trailing, -4)
					
					Image("CoinMoxie", bundle: .main)
						.resizable()
						.aspectRatio(contentMode: .fit)
						.frame(height: 35)
				}
				.frame(maxHeight: .infinity)
				
				Text("~$\(dollarValue.formatted(.number.precision(.fractionLength(2))))")
					.font(.caption)
					.fontDesign(.rounded)
					.foregroundStyle(Color.white)
					.fontWeight(.light)
			}
			.padding(.all, 0)
			
			Spacer()
			
			Menu {
				Text(info)
			} label: {
				Image(systemName: "info.circle")
					.resizable()
					.aspectRatio(contentMode: .fit)
					.frame(width: 25)
					.padding(.trailing)
					.tint(Color(uiColor: MoxieColor.otherColor))
			}
		}
		.padding(.vertical)
		.background(Color(uiColor: MoxieColor.primary))
		.clipShape(RoundedRectangle(cornerSize: CGSize(width: 16, height: 16)))
	}
}

#Preview {
	Group {
		CardView(imageSystemName: "laptop.computer", title: "Cast earnings", amount: "2034.34", price: 0.0023, info: "Earnings from casts")
		CardView(imageSystemName: "laptop.computer", title: "Cast earnings", amount: "2034.34", price: 0.0023, info: "Earnings from casts")
		CardView(imageSystemName: "laptop.computer", title: "Cast earnings", amount: "2034.34", price: 0.0023, info: "Earnings from casts")
	}
}
