import SwiftUI
import MoxieLib
import HealthKit
import Sentry

final class HealthKitManager {
	let healthStore = HKHealthStore()

	let readDataTypes: Set = [
		HKObjectType.workoutType(),
		HKObjectType.quantityType(forIdentifier: .stepCount)!,
		HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
		HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
		HKObjectType.quantityType(forIdentifier: .heartRate)!,
		HKObjectType.quantityType(forIdentifier: .restingHeartRate)!
	]

	// Request Authorization
	func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
		healthStore.requestAuthorization(toShare: nil, read: readDataTypes) { success, error in
			completion(success, error)
		}
	}

	func fetchHealthDataForDateRange(start: Date, end: Date, completion: @escaping ([Date: Double]) -> Void) {
		var scoresByDate: [Date: Double] = [:]
		let calendar = Calendar.current

		let healthStore = HKHealthStore()
		let stepQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!

		var date = start
		while date <= end {
			let nextDate = calendar.date(byAdding: .day, value: 1, to: date)!
			let predicate = HKQuery.predicateForSamples(withStart: date, end: nextDate, options: .strictStartDate)

			let query = HKStatisticsQuery(quantityType: stepQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
				if let sum = result?.sumQuantity() {
					let score = sum.doubleValue(for: HKUnit.count())
					scoresByDate[date] = score
				}

				if date == end {
					completion(scoresByDate)
				}
			}

			healthStore.execute(query)
			date = nextDate
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

	func checkNoManualInput(completion: @escaping (Bool) -> Void) {
		guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
			completion(false)
			return
		}

		let startDate = Calendar.current.startOfDay(for: Date())
		let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)

		let queryManualEntry = HKSampleQuery(sampleType: stepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, results, error in
			guard let samples = results as? [HKQuantitySample], error == nil else {
				print("Error fetching steps: \(error?.localizedDescription ?? "Unknown error")")
				return
			}

			for sample in samples {
				if let wasUserEntered = sample.metadata?[HKMetadataKeyWasUserEntered] as? Bool, wasUserEntered {
					print("Steps were manually entered by the user.")
					completion(true)
				} else {
					print("Steps recorded by source: \(sample.sourceRevision.source.name)")
					completion(false)
				}
			}
		}
		healthStore.execute(queryManualEntry)
	}

	// Fetch active calories burned
	func fetchCaloriesBurned(completion: @escaping (Double?, Error?) -> Void) {
		guard let calorieType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
			completion(nil, nil)
			return
		}

		let calendar = Calendar.current
		var dateComponents = DateComponents()

		dateComponents.year = 2024
		dateComponents.month = 10
		dateComponents.day = 21

		let startDate = calendar.date(from: dateComponents) ?? Date()

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

	func getAverageHeartRate(completion: @escaping (Double?, Error?) -> Void) {
		let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!

		let now = Date()
		guard let startDate = Calendar.current.date(byAdding: .month, value: -1, to: now) else {
			completion(nil, nil)
			return
		}
		let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)

		let query = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, results, error in
			guard let samples = results as? [HKQuantitySample], error == nil else {
				completion(nil, error)
				return
			}

			guard !samples.isEmpty else {
				completion(nil, nil)
				return
			}

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
	var healthKitManager = HealthKitManager()

	@Published var steps: Decimal = 0.0
	@Published var caloriesBurned: Decimal = 0.0
	@Published var distanceTraveled: Decimal = 0.0
	@Published var restingHeartRate: Decimal = 0.0
	@Published var averageHeartRate: Decimal = 0.0
	@Published var estimatedRewardPoints: Decimal = 0.0

	init(healthKitManager: HealthKitManager = HealthKitManager(), steps: Decimal = 0, caloriesBurned: Decimal = 0, distanceTraveled: Decimal = 0, restingHeartRate: Decimal = 0) {
		self.healthKitManager = healthKitManager
		self.steps = steps
		self.caloriesBurned = caloriesBurned
		self.distanceTraveled = distanceTraveled
		self.restingHeartRate = restingHeartRate

		fetchHealthData()

		self.estimatedRewardPoints = calculateRewardPoints(
			activity: ActivityData(
				steps: steps,
				caloriesBurned: caloriesBurned,
				distance: distanceTraveled,
				avgHeartRate: restingHeartRate
			)
		)
	}

	func calculateRewardPoints(activity: ActivityData) -> Decimal {
		let maxSteps: Decimal = 10000.0
		let maxCalories: Decimal = 500.0

		let stepPoints = (activity.steps / maxSteps) * stepWeight
		let caloriePoints = (activity.caloriesBurned / maxCalories) * calorieWeight
		let distancePoints = (activity.distance) * distanceWeight
		let heartRatePoints = heartRateMultiplier(for: activity.avgHeartRate) * heartRateWeight * 1000

		let basePoints = stepPoints + caloriePoints + distancePoints + heartRatePoints

		return basePoints
	}

	func createActivityData(completion: @escaping (Decimal) -> Void) {
		let calendar = Calendar.current
		let startDate = calendar.date(from: DateComponents(year: 2024, month: 10, day: 21))!
		let endDate = calendar.date(from: DateComponents(year: 2024, month: 10, day: 28))!

		fetchHealthDataForDateRangeWeek(start: startDate, end: endDate) { results in
			let activity = ActivityData(steps: results["steps"] ?? 0,
																	caloriesBurned: results["calories"] ?? 0,
																	distance: results["distance"] ?? 0,
																	avgHeartRate: results["heartRate"] ?? 0)

			dump(activity)
			let result = self.calculateRewardPoints(activity: activity)

			completion(result)
		}
	}

	func fetchHealthDataForDateRangeWeek(start: Date, end: Date, completion: @escaping ([String: Decimal]) -> Void) {
		healthKitManager.checkNoManualInput { isManualInput in
			guard !isManualInput else {
				completion(["steps": 0, "calories": 0, "distance": 0, "heartRate": 0])
				return
			}

			let healthStore = HKHealthStore()
			let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)

			let stepQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
			let calorieQuantityType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
			let distanceQuantityType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
			let heartRateQuantityType = HKQuantityType.quantityType(forIdentifier: .heartRate)!

			// Store results in a dictionary
			var results: [String: Decimal] = ["steps": 0, "calories": 0, "distance": 0, "heartRate": 0]
			let group = DispatchGroup()

			// Steps Query
			group.enter()
			let stepQuery = HKStatisticsQuery(quantityType: stepQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
				if let sum = result?.sumQuantity() {
					results["steps"] = Decimal(sum.doubleValue(for: HKUnit.count()))
				}
				group.leave()
			}
			healthStore.execute(stepQuery)

			// Calories Query
			group.enter()
			let calorieQuery = HKStatisticsQuery(quantityType: calorieQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
				if let sum = result?.sumQuantity() {
					results["calories"] = Decimal(sum.doubleValue(for: HKUnit.kilocalorie()))
				}
				group.leave()
			}
			healthStore.execute(calorieQuery)

			// Distance Query
			group.enter()
			let distanceQuery = HKStatisticsQuery(quantityType: distanceQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
				if let sum = result?.sumQuantity() {
					results["distance"] = Decimal(sum.doubleValue(for: HKUnit.meter()) / 1000) // Convert to kilometers
				}
				group.leave()
			}
			healthStore.execute(distanceQuery)

			// Heart Rate Query (average)
			group.enter()
			let heartRateQuery = HKStatisticsQuery(quantityType: heartRateQuantityType, quantitySamplePredicate: predicate, options: .discreteAverage) { _, result, _ in
				if let avg = result?.averageQuantity() {
					results["heartRate"] = Decimal(avg.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute())))
				}
				group.leave()
			}
			healthStore.execute(heartRateQuery)

			// Completion handler after all queries complete
			group.notify(queue: .main) {
				completion(results)
			}
		}
	}

	func fetchHealthDataForDateRange(start: Date, end: Date, completion: @escaping (Decimal) -> Void) {
		let calendar = Calendar.current
		let healthStore = HKHealthStore()
		let stepQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!

		let startDate = calendar.date(from: DateComponents(year: 2024, month: 10, day: 21))!
		let endDate = calendar.date(from: DateComponents(year: 2024, month: 10, day: 28))!

		let predicate = HKQuery.predicateForSamples(
			withStart: startDate,
			end: endDate,
			options: .strictStartDate
		)

		let query = HKStatisticsQuery(quantityType: stepQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
			if let sum = result?.sumQuantity() {
				let score = sum.doubleValue(for: HKUnit.count())
				completion(Decimal(score))
			}
		}

		healthStore.execute(query)
	}

	// Request HealthKit access and fetch all required data
	func requestHealthKitAccess() {
		healthKitManager.requestAuthorization { [weak self] (success, error) in
			if success {
				self?.fetchHealthData()
			} else {
				if let error {
					SentrySDK.capture(error: error)
					print("Authorization failed with error: \(String(describing: error))")
				}
			}
		}
	}

	// Fetch all required health data (steps, calories, distance, resting heart rate)
	func fetchHealthData() {
		fetchSteps()
		fetchCaloriesBurned()
		fetchDistanceTraveled()
		fetchRestingHeartRate()
		fetchAverageHeartRate()
	}

	// Fetch today's step count
	func fetchSteps() {
		healthKitManager.getTodayStepCount { [weak self] (steps, error) in
			DispatchQueue.main.async {
				if let error {
					SentrySDK.capture(event: .init(error: MoxieError.message("Error fetching steps \(error)")))
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
					SentrySDK.capture(event: .init(error: MoxieError.message("Error fetching calories \(error)")))
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
					SentrySDK.capture(event: .init(error: MoxieError.message("Error fetching distance \(error)")))
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
					SentrySDK.capture(error: error)
					print("Error fetching resting heart rate: \(error)")
				} else {
					self?.restingHeartRate = Decimal(heartRate ?? 0)
				}
			}
		}
	}

	func fetchAverageHeartRate() {
		healthKitManager.fetchAverageHeartRateForOctober { avgHR in
			self.averageHeartRate = Decimal(avgHR ?? 0)
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

	// Step 2: Fetch Workouts
	func fetchWorkouts(from startDate: Date, to endDate: Date, completion: @escaping ([HKWorkout]) -> Void) {
		let workoutType = HKObjectType.workoutType()

		// Set the date range predicate
		let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

		// Create the query with the date range predicate
		let query = HKSampleQuery(sampleType: workoutType, predicate: predicate, limit: 0, sortDescriptors: nil) { (_, results, error) in
			guard let workouts = results as? [HKWorkout], error == nil else {
				print("Error fetching workouts: \(error?.localizedDescription ?? "unknown error")")
				return
			}

			completion(workouts)
		}

		healthStore.execute(query)
	}

	// Example usage
	func fetchWorkoutsForOctober() {
		let calendar = Calendar.current
		let startDate = calendar.date(from: DateComponents(year: 2024, month: 10, day: 21))!
		let endDate = calendar.date(from: DateComponents(year: 2024, month: 10, day: 28))!

		fetchWorkouts(from: startDate, to: endDate) { workouts in
			for workout in workouts {
				print("Workout type: \(workout.workoutActivityType.rawValue), Duration: \(workout.duration), Calories burned: \(workout.totalEnergyBurned?.doubleValue(for: .kilocalorie()) ?? 0) kcal")
			}
		}
	}

	// Step 3: Fetch Heart Rate for a Workout and Calculate Average
	func fetchAverageHeartRate(for workout: HKWorkout, completion: @escaping (Double?) -> Void) {
		let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
		let workoutPredicate = HKQuery.predicateForSamples(withStart: workout.startDate, end: workout.endDate, options: .strictStartDate)

		let query = HKStatisticsQuery(quantityType: heartRateType, quantitySamplePredicate: workoutPredicate, options: .discreteAverage) { (_, result, _) in
			guard let avgHeartRate = result?.averageQuantity() else {
				completion(nil)
				return
			}

			let avgHeartRateValue = avgHeartRate.doubleValue(for: HKUnit(from: "count/min"))
			completion(avgHeartRateValue)
		}

		healthStore.execute(query)
	}

	func fetchAverageHeartRateForOctober(completion: @escaping (Double?) -> Void) {
		let healthStore = HKHealthStore()
		let workoutType = HKObjectType.workoutType()

		let calendar = Calendar.current
		let startDate = calendar.date(from: DateComponents(year: 2024, month: 10, day: 1))!
		let endDate = calendar.date(from: DateComponents(year: 2024, month: 10, day: 31, hour: 23, minute: 59, second: 59))!

		// Predicate to filter workouts within October
		let datePredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

		// Query to fetch workouts within the date range
		let workoutQuery = HKSampleQuery(sampleType: workoutType, predicate: datePredicate, limit: 0, sortDescriptors: nil) { (_, results, error) in
			guard let workouts = results as? [HKWorkout], error == nil else {
				print("Error fetching workouts: \(error?.localizedDescription ?? "unknown error")")
				completion(nil)
				return
			}

			// Array to store average heart rate for each workout
			var totalHeartRate = 0.0
			var heartRateCount = 0

			let dispatchGroup = DispatchGroup()

			// Loop through each workout and fetch average heart rate
			for workout in workouts {
				dispatchGroup.enter()
				self.fetchAverageHeartRateForWorkout(workout: workout) { avgHeartRate in
					if let avgHeartRate = avgHeartRate {
						totalHeartRate += avgHeartRate
						heartRateCount += 1
					}
					dispatchGroup.leave()
				}
			}

			// Wait for all heart rate queries to complete
			dispatchGroup.notify(queue: .main) {
				if heartRateCount > 0 {
					let overallAverageHeartRate = totalHeartRate / Double(heartRateCount)
					completion(overallAverageHeartRate)
				} else {
					completion(nil)
				}
			}
		}

		healthStore.execute(workoutQuery)
	}

	func fetchAverageHeartRateForWorkout(workout: HKWorkout, completion: @escaping (Double?) -> Void) {
		let healthStore = HKHealthStore()
		let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!

		// Predicate to filter heart rate samples within the workout duration
		let predicate = HKQuery.predicateForSamples(withStart: workout.startDate, end: workout.endDate, options: .strictStartDate)

		// Query to get heart rate data for the workout
		let heartRateQuery = HKStatisticsQuery(quantityType: heartRateType, quantitySamplePredicate: predicate, options: .discreteAverage) { (_, result, error) in
			guard let avgHeartRate = result?.averageQuantity() else {
				print("Error fetching heart rate for workout: \(error?.localizedDescription ?? "unknown error")")
				completion(nil)
				return
			}

			let heartRateValue = avgHeartRate.doubleValue(for: HKUnit(from: "count/min"))
			completion(heartRateValue)
		}

		healthStore.execute(heartRateQuery)
	}

}
