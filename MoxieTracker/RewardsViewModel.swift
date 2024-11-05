import HealthKit
import SwiftUI

struct ActivityData {
	var steps: Double
	var caloriesBurned: Double
	var distance: Double
	var avgHeartRate: Double
}

let stepWeight: Double = 0.3
let calorieWeight: Double = 0.3
let distanceWeight: Double = 0.2
let heartRateWeight: Double = 0.2

func heartRateMultiplier(for avgHeartRate: Decimal) -> Decimal {
	switch avgHeartRate {
	case 90...120: return 1.3
	case 121...150: return 1.5
	case 151...250: return 1.8
	default: return 1.0
	}
}
