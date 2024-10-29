import HealthKit
import SwiftUI

struct ActivityData {
	var steps: Decimal
	var caloriesBurned: Decimal
	var distance: Decimal
	var avgHeartRate: Decimal
}

let stepWeight: Decimal = 0.4
let calorieWeight: Decimal = 0.3
let distanceWeight: Decimal = 0.2
let heartRateWeight: Decimal = 0.1

func heartRateMultiplier(for avgHeartRate: Decimal) -> Decimal {
	switch avgHeartRate {
	case 90...120: return 1.0
	case 121...150: return 1.5
	case 151...250: return 2.0
	default: return 1.0
	}
}
