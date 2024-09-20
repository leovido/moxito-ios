import Foundation

public func formattedDollarValue(dollarValue: Decimal, locale: Locale = .autoupdatingCurrent) -> String {
	let numberFormatter = NumberFormatter()
	numberFormatter.numberStyle = .currency
	numberFormatter.currencyCode = "USD"
	numberFormatter.currencySymbol = "$"
	
	// Make sure to use the current locale
	numberFormatter.locale = locale
	
	if let formattedValue = numberFormatter.string(from: dollarValue as NSDecimalNumber) {
		return formattedValue
	} else {
		return "$0.00"
	}
}
