import SwiftUI
import MoxieLib

struct CardView: View {
	@Environment(\.locale) var locale

	let imageSystemName: String
	let title: String
	let amount: String
	let price: Decimal
	
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
			Image(systemName: imageSystemName)
				.resizable()
				.renderingMode(.template)
				.aspectRatio(contentMode: .fit)
				.frame(width: 40)
				.padding(.trailing)
				.foregroundStyle(Color(uiColor: MoxieColor.otherColor))
			
			VStack(alignment: .leading) {
				Text(title)
					.font(.headline)
					.fontDesign(.rounded)
					.foregroundStyle(Color(uiColor: MoxieColor.otherColor))
					.fontWeight(.semibold)
				Text(amount)
					.font(.title2)
					.fontDesign(.rounded)
					.foregroundStyle(Color(uiColor: MoxieColor.otherColor).blendMode(.difference))
					.fontWeight(.medium)
				Text("$\(dollarValue.formatted(.number.precision(.fractionLength(2))))")
					.font(.caption)
					.fontDesign(.rounded)
					.foregroundStyle(Color(uiColor: MoxieColor.otherColor).blendMode(.difference).opacity(0.9))
					.fontWeight(.medium)
			}
			
			Spacer()
			
			Menu {
				Text("This")
				Text("That")
			} label: {
				Image(systemName: "info.circle")
					.resizable()
					.aspectRatio(contentMode: .fit)
					.frame(width: 25)
					.padding(.trailing)
					.tint(Color(uiColor: MoxieColor.otherColor))
			}
			
		}
		.padding()
		.background(Color.init(uiColor: MoxieColor.dark))
	}
}

#Preview {
	Group {
		CardView(imageSystemName: "laptop.computer", title: "Cast earnings", amount: "2034.34", price: 0.0023)
		CardView(imageSystemName: "laptop.computer", title: "Cast earnings", amount: "2034.34", price: 0.0023)
		CardView(imageSystemName: "laptop.computer", title: "Cast earnings", amount: "2034.34", price: 0.0023)
	}
}
