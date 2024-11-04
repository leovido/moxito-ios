import HealthKit
import SwiftUI

struct ActivityData {
	var steps: Decimal
	var caloriesBurned: Decimal
	var distance: Decimal
	var avgHeartRate: Decimal
}

let stepWeight: Decimal = 0.3
let calorieWeight: Decimal = 0.3
let distanceWeight: Decimal = 0.2
let heartRateWeight: Decimal = 0.2

func heartRateMultiplier(for avgHeartRate: Decimal) -> Decimal {
	switch avgHeartRate {
	case 90...120: return 1.3
	case 121...150: return 1.5
	case 151...250: return 1.8
	default: return 1.0
	}
}
