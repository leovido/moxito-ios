import SwiftUI
import MoxieLib
import Sentry

enum FitnessCardType: String, CaseIterable {
	case calories
	case distance
	case heartRate
}

struct FitnessCardView: View {
	@Environment(\.locale) var locale

	let imageSystemName: String
	let title: String
	let amount: Decimal
	let noFormatting: Bool
	let type: FitnessCardType

	var iconColor: Color {
		return Color(uiColor: MoxieColor.green)
		switch type {
		case .calories:
			return Color.yellow
		case .distance:
			return Color.blue
		case .heartRate:
			return Color.pink
		}
	}

	var measurement: String {
		switch type {
		case .calories:
			return "kcal"
		case .distance:
			return "km"
		case .heartRate:
			return "bpm"
		}
	}

	init(imageSystemName: String, title: String, amount: Decimal, noFormatting: Bool = false, type: FitnessCardType) {
		self.imageSystemName = imageSystemName
		self.title = title
		self.amount = amount
		self.noFormatting = noFormatting
		self.type = type
	}

	var amountFormatted: String {
		let numberFormatter = NumberFormatter()

		// Make sure to use the current locale
		numberFormatter.locale = .current

		if let formattedValue = numberFormatter.string(from: amount as NSDecimalNumber) {
			return formattedValue
		} else {
			return "0.00"
		}
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
							.fill(iconColor)
					)
			}
			.frame(width: 40, height: 40)
			.padding(.trailing, 12)

			VStack(alignment: .leading) {
				Text(title)
					.scaledToFit()
					.font(.headline)
					.font(.custom("Inter", size: 20))
					.foregroundStyle(Color.white)

				HStack(alignment: .lastTextBaseline) {
					Text(noFormatting ? amount.formatted(.number.precision(.fractionLength(0))) : amountFormatted)
						.font(.title)
						.font(.custom("Inter", size: 20))
						.foregroundStyle(Color.white)
						.fontWeight(.heavy)
						.padding(.trailing, -4)

					Text(measurement)
						.font(.caption)
						.font(.custom("Inter", size: 15))
						.foregroundStyle(Color.white)
						.fontWeight(.light)

				}
			}
			.padding(.all, 0)

			Spacer()

		}
		.padding()
		.background(Color(uiColor: MoxieColor.primary))
		.clipShape(RoundedRectangle(cornerSize: CGSize(width: 16, height: 16)))
	}
}

#Preview {
	Group {
		FitnessCardView(imageSystemName: "laptop.computer", title: "Cast earnings", amount: 2034.34, type: .calories)
		FitnessCardView(imageSystemName: "laptop.computer", title: "Cast earnings", amount: 2034.34, type: .distance)
		FitnessCardView(imageSystemName: "laptop.computer", title: "Cast earnings", amount: 2034.34, type: .heartRate)
	}
}
