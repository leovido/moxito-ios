import SwiftUI
import MoxieLib
import HealthKit
import Sentry

final class HealthKitManager {
	let healthStore = HKHealthStore()

	let readDataTypes: Set = [
		HKObjectType.quantityType(forIdentifier: .stepCount)!,
		HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
		HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
		HKObjectType.quantityType(forIdentifier: .restingHeartRate)!
	]

	// Request Authorization
	func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
		healthStore.requestAuthorization(toShare: nil, read: readDataTypes) { success, error in
			completion(success, error)
		}
	}

	// Fetch step count for the current day
	func fetchStepCount(completion: @escaping (Double?) -> Void) {
		guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
			completion(nil)
			return
		}

		let startDate = Calendar.current.startOfDay(for: Date())
		let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)

		let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
			guard let result = result, let sum = result.sumQuantity() else {
				completion(nil)
				return
			}
			completion(sum.doubleValue(for: HKUnit.count()))
		}
		healthStore.execute(query)
	}

	// Fetch active calories burned
	func fetchCaloriesBurned(completion: @escaping (Double?, Error?) -> Void) {
		guard let calorieType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
			completion(nil, nil)
			return
		}

		let calendar = Calendar.current
		guard let startDate = calendar.date(byAdding: .day, value: -2, to: Date()) else {
			completion(nil, nil)
			return
		}

		let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)

		let query = HKStatisticsQuery(quantityType: calorieType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
			guard let result = result, let sum = result.sumQuantity() else {
				completion(nil, error)
				return
			}
			completion(sum.doubleValue(for: HKUnit.kilocalorie()), nil)
		}
		healthStore.execute(query)
	}

	// Fetch the resting heart rate data for the past month and calculate the average
	func getRestingHeartRateForMonth(completion: @escaping (Double?, Error?) -> Void) {
		let heartRateType = HKQuantityType.quantityType(forIdentifier: .restingHeartRate)!

		let now = Date()
		guard let startDate = Calendar.current.date(byAdding: .month, value: -1, to: now) else {
			completion(nil, nil) // If start date calculation fails, return no data.
			return
		}
		let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)

		let query = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, results, error in
			guard let samples = results as? [HKQuantitySample], error == nil else {
				completion(nil, error)
				return
			}

			// If there are no samples, return nil
			guard !samples.isEmpty else {
				completion(nil, nil)
				return
			}

			// Calculate the average heart rate over the last month
			let totalHeartRate = samples.reduce(0.0) { sum, sample in
				sum + sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
			}
			let averageHeartRate = totalHeartRate / Double(samples.count)
			completion(averageHeartRate, nil)
		}

		healthStore.execute(query)
	}

	// Fetch distance walked/running
	func fetchDistance(completion: @escaping (Double?, Error?) -> Void) {
		guard let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else {
			completion(nil, nil)
			return
		}

		let startDate = Calendar.current.startOfDay(for: Date())
		let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)

		let query = HKStatisticsQuery(quantityType: distanceType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
			guard let result = result, let sum = result.sumQuantity() else {
				completion(nil, error)
				return
			}
			completion(sum.doubleValue(for: HKUnit.meter()), nil)
		}
		healthStore.execute(query)
	}

	// Fetch heart rate for the current day
	func fetchHeartRate(completion: @escaping ([Double], Error?) -> Void) {
		guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
			completion([], nil)
			return
		}

		let startDate = Calendar.current.startOfDay(for: Date())
		let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)

		let query = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, results, error in
			guard let results = results as? [HKQuantitySample] else {
				completion([], error)
				return
			}
			let heartRates = results.map { $0.quantity.doubleValue(for: HKUnit(from: "count/min")) }
			completion(heartRates, nil)
		}
		healthStore.execute(query)
	}
}

final class StepCountViewModel: ObservableObject {
	private var healthKitManager = HealthKitManager()

	@Published var steps: Decimal = 0.0
	@Published var caloriesBurned: Decimal = 0.0
	@Published var distanceTraveled: Decimal = 0.0
	@Published var restingHeartRate: Decimal = 0.0

	init(healthKitManager: HealthKitManager = HealthKitManager(), steps: Decimal = 0, caloriesBurned: Decimal = 0, distanceTraveled: Decimal = 0, restingHeartRate: Decimal = 0) {
		self.healthKitManager = healthKitManager
		self.steps = steps
		self.caloriesBurned = caloriesBurned
		self.distanceTraveled = distanceTraveled
		self.restingHeartRate = restingHeartRate

		fetchHealthData()
	}

	// Request HealthKit access and fetch all required data
	func requestHealthKitAccess() {
		healthKitManager.requestAuthorization { [weak self] (success, error) in
			if success {
				self?.fetchHealthData()
			} else {
				print("Authorization failed with error: \(String(describing: error))")
			}
		}
	}

	// Fetch all required health data (steps, calories, distance, resting heart rate)
	func fetchHealthData() {
		fetchSteps()
		fetchCaloriesBurned()
		fetchDistanceTraveled()
		fetchRestingHeartRate()
	}

	// Fetch today's step count
	func fetchSteps() {
		healthKitManager.getTodayStepCount { [weak self] (steps, error) in
			DispatchQueue.main.async {
				if let error = error {
					print("Error fetching steps: \(error)")
				} else {
					self?.steps = Decimal(steps)
				}
			}
		}
	}

	// Fetch today's calories burned
	func fetchCaloriesBurned() {
		healthKitManager.fetchCaloriesBurned { [weak self] (calories, error) in
			DispatchQueue.main.async {
				if let error = error {
					print("Error fetching calories: \(error)")
				} else {
					self?.caloriesBurned = Decimal(calories ?? 0)
				}
			}
		}
	}

	// Fetch today's distance traveled
	func fetchDistanceTraveled() {
		healthKitManager.fetchDistance { [weak self] (distance, error) in
			DispatchQueue.main.async {
				if let error = error {
					SentrySDK.capture(error: MoxieError.message("Error fetching distance \(error)"))
				} else {
					guard let distance = distance else {
						return
					}
					self?.distanceTraveled = Decimal(distance) / 1000
				}
			}
		}
	}

	// Fetch resting heart rate
	func fetchRestingHeartRate() {
		healthKitManager.getRestingHeartRateForMonth { [weak self] (heartRate, error) in
			DispatchQueue.main.async {
				if let error = error {
					print("Error fetching resting heart rate: \(error)")
				} else {
					self?.restingHeartRate = Decimal(heartRate ?? 0)
				}
			}
		}
	}
}

extension HealthKitManager {
	func getTodayStepCount(completion: @escaping (Double, Error?) -> Void) {
		guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
			fatalError("Step Count Type is no longer available in HealthKit")
		}

		let startDate = Calendar.current.startOfDay(for: Date())
		let endDate = Date()

		let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

		let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { (_, result, error) in
			guard let result = result, let sum = result.sumQuantity() else {
				completion(0.0, error)
				return
			}
			let stepCount = sum.doubleValue(for: HKUnit.count())
			completion(stepCount, nil)
		}

		healthStore.execute(query)
	}
}
