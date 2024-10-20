import SwiftUI
import MoxieLib
import Sentry

struct CardView: View {
	@Environment(\.locale) var locale

	let imageSystemName: String
	let title: String
	let amount: Decimal
	let price: Decimal
	let info: String

	var amountFormatted: String {
		let numberFormatter = NumberFormatter()
		numberFormatter.numberStyle = .currency
		numberFormatter.currencySymbol = ""

		// Make sure to use the current locale
		numberFormatter.locale = .current

		if let formattedValue = numberFormatter.string(from: amount as NSDecimalNumber) {
			return formattedValue
		} else {
			return "$0.00"
		}
	}

	var dollarValue: Decimal {
		let am = price * amount

		return am
	}

	var body: some View {
		HStack {
			VStack {
				Image(systemName: imageSystemName)
					.resizable()
					.renderingMode(.template)
					.aspectRatio(contentMode: .fit)
					.padding(10)
					.foregroundColor(.white)
					.background(
						RoundedRectangle(cornerRadius: 10)
							.fill(Color(uiColor: MoxieColor.green))
					)
			}
			.frame(width: 40, height: 40)
			.padding(.leading)
			.padding(.trailing, 12)

			VStack(alignment: .leading, spacing: 0) {
				Text(title)
					.scaledToFit()
					.font(.headline)
					.font(.custom("Inter", size: 20))
					.foregroundStyle(Color.white)

				if !amountFormatted.isEmpty {
					HStack(spacing: 1) {
						Text(amountFormatted)
							.font(.title)
							.font(.custom("Inter", size: 20))
							.foregroundStyle(Color.white)
							.fontWeight(.heavy)
							.padding(.trailing, -4)

						Image("CoinMoxie", bundle: .main)
							.resizable()
							.aspectRatio(contentMode: .fit)
							.frame(height: 35)
					}
					.frame(maxHeight: .infinity)
				}

				Text("~\(formattedDollarValue(dollarValue: dollarValue))")
					.font(.caption)
					.font(.custom("Inter", size: 20))
					.foregroundStyle(Color.white)
					.fontWeight(.light)
			}
			.padding(.all, 0)

			Spacer()

			if !info.isEmpty {
				Menu {
					Text(info)
				} label: {
					Image(systemName: "info.circle.fill")
						.resizable()
						.aspectRatio(contentMode: .fit)
						.frame(width: 25)
						.padding(.trailing)
						.tint(Color(uiColor: MoxieColor.otherColor))
				}
			}
		}
		.padding(.vertical)
		.background(Color(uiColor: MoxieColor.primary))
		.clipShape(RoundedRectangle(cornerSize: CGSize(width: 16, height: 16)))
	}
}

#Preview {
	Group {
		CardView(imageSystemName: "laptop.computer", title: "Cast earnings", amount: 2034.34, price: 0.0023, info: "Earnings from casts")
		CardView(imageSystemName: "laptop.computer", title: "Cast earnings", amount: 2034.34, price: 0.0023, info: "Earnings from casts")
		CardView(imageSystemName: "laptop.computer", title: "Cast earnings", amount: 2034.34, price: 0.0023, info: "Earnings from casts")
	}
}
