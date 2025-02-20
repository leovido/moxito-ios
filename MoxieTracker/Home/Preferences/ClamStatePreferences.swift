import SwiftUI

struct ClaimStatePreferenceKey: PreferenceKey {
	static var defaultValue: ClaimState = .idle
	
	static func reduce(value: inout ClaimState, nextValue: () -> ClaimState) {
		value = nextValue()
	}
}

enum ClaimState: Hashable {
	case idle
	case claiming(progress: Double)
	case completed
	case failed(ClaimError)
}

enum ClaimError: Error, Hashable {
	case networkError
	case invalidTransaction
	case insufficientFunds
	case unknown(String)
}
