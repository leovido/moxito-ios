import HealthKit

final class HealthKitManager {
	private let healthStore = HKHealthStore()

	private let readDataTypes: Set = [
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
	func fetchStepCount(startDate: Date, endDate: Date, completion: @escaping (Double?) -> Void) {
		guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
			completion(nil)
			return
		}

		let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

		let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in

			guard let result = result,
						let sum = result.sumQuantity() else {
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
					completion(false)
				}
			}
		}
		healthStore.execute(queryManualEntry)
	}

	func fetchCaloriesBurned(startDate: Date, endDate: Date, completion: @escaping (Double?, Error?) -> Void) {
		guard let calorieType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
			completion(nil, nil)
			return
		}

		let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

		let query = HKSampleQuery(sampleType: calorieType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
			guard let samples = samples as? [HKQuantitySample], error == nil else {
				completion(0, error)
				return
			}

			let totalCalories = samples.reduce(0.0) { sum, sample in
				if let wasUserEntered = sample.metadata?[HKMetadataKeyWasUserEntered] as? Bool, wasUserEntered {
					print("Excluding manual calorie entry: \(sample.quantity.doubleValue(for: HKUnit.kilocalorie())) kcal")
					return sum
				}
				return sum + sample.quantity.doubleValue(for: HKUnit.kilocalorie())
			}

			completion(totalCalories, nil)
		}

		healthStore.execute(query)
	}

	func getRestingHeartRateForMonth(startDate: Date, endDate: Date, completion: @escaping (Double?, Error?) -> Void) {
		let heartRateType = HKQuantityType.quantityType(forIdentifier: .restingHeartRate)!

		let predicate = HKQuery.predicateForSamples(
			withStart: startDate,
			end: endDate,
			options: .strictStartDate
		)

		let query = HKSampleQuery(
			sampleType: heartRateType,
			predicate: predicate,
			limit: HKObjectQueryNoLimit,
			sortDescriptors: nil
		) { _, results, error in
			guard let samples = results as? [HKQuantitySample], error == nil else {
				completion(nil, error)
				return
			}

			let filteredSamples = samples.filter { sample in
				if let wasUserEntered = sample.metadata?[HKMetadataKeyWasUserEntered] as? Bool, wasUserEntered {
					print("Excluding manual heart rate entry: \(sample.quantity.doubleValue(for: HKUnit(from: "count/min"))) bpm")
					return false
				}
				return true
			}

			guard !filteredSamples.isEmpty else {
				completion(nil, nil)
				return
			}

			let totalHeartRate = filteredSamples.reduce(0.0) { sum, sample in
				sum + sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
			}
			let averageHeartRate = totalHeartRate / Double(filteredSamples.count)
			completion(averageHeartRate, nil)
		}

		healthStore.execute(query)
	}

	func getAverageHeartRate(startDate: Date, endDate: Date, completion: @escaping (Double?, Error?) -> Void) {
		let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!

		let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

		let query = HKSampleQuery(
			sampleType: heartRateType,
			predicate: predicate,
			limit: HKObjectQueryNoLimit,
			sortDescriptors: nil
		) { _, results, error in
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
	func fetchDistance(startDate: Date, endDate: Date, completion: @escaping (Double?, Error?) -> Void) {
		guard let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else {
			completion(nil, nil)
			return
		}

		let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

		let query = HKSampleQuery(sampleType: distanceType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
			guard let samples = samples as? [HKQuantitySample], error == nil else {
				completion(0, error)
				return
			}

			let totalDistance = samples.reduce(0.0) { sum, sample in
				if let wasUserEntered = sample.metadata?[HKMetadataKeyWasUserEntered] as? Bool, wasUserEntered {
					print("Excluding manual distance entry: \(sample.quantity.doubleValue(for: HKUnit.meter())) meters")
					return sum
				}
				return sum + sample.quantity.doubleValue(for: HKUnit.meter())
			}

			completion(totalDistance, nil)
		}

		healthStore.execute(query)
	}
}

extension HealthKitManager {
	func getTodayStepCount(startDate: Date, endDate: Date, completion: @escaping (Double, Error?) -> Void) {
		guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
			fatalError("Step Count Type is no longer available in HealthKit")
		}

		let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

		let query = HKSampleQuery(sampleType: stepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
			guard let samples = samples as? [HKQuantitySample], error == nil else {
				completion(0.0, error)
				return
			}

			let totalSteps = samples.reduce(0.0) { sum, sample in
				if let wasUserEntered = sample.metadata?[HKMetadataKeyWasUserEntered] as? Bool, wasUserEntered {
					print("Excluding manual entry: \(sample.quantity.doubleValue(for: HKUnit.count())) steps")
					return sum
				}
				return sum + sample.quantity.doubleValue(for: HKUnit.count())
			}

			completion(totalSteps, nil)
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

	func fetchAvgHRWorkouts(startDate: Date, endDate: Date, completion: @escaping (Double?) -> Void) {
		let workoutType = HKObjectType.workoutType()

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
