import Foundation

// MARK: - CherylWidgetModel
public struct CherylWidgetModel: Codable {
	public let isEligible: Bool
	public let requiredMoxie: Decimal
	public let currentPriceInMoxie: String
	public let currentFTMoxieValue, totalHoldings: Decimal
	public let neededFTs: Decimal
	
	public init(isEligible: Bool, requiredMoxie: Decimal, currentPriceInMoxie: String, currentFTMoxieValue: Decimal, totalHoldings: Decimal, neededFTs: Decimal) {
		self.isEligible = isEligible
		self.requiredMoxie = requiredMoxie
		self.currentPriceInMoxie = currentPriceInMoxie
		self.currentFTMoxieValue = currentFTMoxieValue
		self.totalHoldings = totalHoldings
		self.neededFTs = neededFTs
	}
}
