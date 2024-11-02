import SwiftUI
import MoxieLib
import HealthKit
import Combine
import Sentry
import MoxitoLib

enum Result<T: Hashable, E: Hashable>: Hashable {
	case success(T)
	case error(E)
}

enum HealthKitError: Error {
	case noAuthorization
	case noData
}

enum StepCountAction: Hashable {
	case fetchHealthData
	case receiveHealthKitAccess(Result<Bool, HealthKitError>)
	case checkFIDPoints
	case onAppear
	case requestAuthorizationHealthKit
	case calculatePoints(startDate: Date, endDate: Date)
}

@MainActor
final class StepCountViewModel: ObservableObject, Observable {
	let healthKitManager: HealthKitManager

	@Published var steps: Decimal = 0.0
	@Published var caloriesBurned: Decimal = 0.0
	@Published var distanceTraveled: Decimal = 0.0
	@Published var restingHeartRate: Decimal = 0.0
	@Published var averageHeartRate: Decimal = 0.0
	@Published var estimatedRewardPoints: Decimal = 0.0
	@Published var didAuthorizeHealthKit: Bool = false
	@Published var filterSelection: Int = 0 {
		didSet {
			fetchHealthData()
		}
	}
	@Published var stepsLimit: Decimal = 10000

	@Published var currentWeekStartDate = Calendar.current.nextMonday(for: Date())
	@Published var allWeeksData: [Date: [Day]] = [:]

	let client: MoxitoClient

	let actions: PassthroughSubject<StepCountAction, Never> = .init()
	private(set) var subscriptions: Set<AnyCancellable> = []

	init(healthKitManager: HealthKitManager = HealthKitManager(), steps: Decimal = 0, caloriesBurned: Decimal = 0, distanceTraveled: Decimal = 0, restingHeartRate: Decimal = 0, didAuthorizeHealthKit: Bool = false,
			 client: MoxitoClient = .init()) {
		self.healthKitManager = healthKitManager
		self.steps = steps
		self.caloriesBurned = caloriesBurned
		self.distanceTraveled = distanceTraveled
		self.restingHeartRate = restingHeartRate
		self.didAuthorizeHealthKit = didAuthorizeHealthKit
		self.client = client

		let sharedPublisher = actions.share()

		sharedPublisher.sink { [weak self] action in
			switch action {
			case .requestAuthorizationHealthKit:
				Task {
					try await self?.requestHealthKitAccess()

				}
			case .fetchHealthData:
				self?.fetchHealthData()
			case .onAppear:
				return
			case .calculatePoints(let startDate, let endDate):
				self?.calculateTotalPoints(startDate: startDate, endDate: endDate)
			case .checkFIDPoints:
				return
			case .receiveHealthKitAccess(.success(let isSuccess)):
				self?.didAuthorizeHealthKit = isSuccess

				self?.actions.send(.fetchHealthData)
			case .receiveHealthKitAccess(.error(let error)):
				self?.didAuthorizeHealthKit = false
			}
		}
		.store(in: &subscriptions)

		$filterSelection
			.sink { [weak self] newSelection in
				switch newSelection {
				case 0:
					self?.stepsLimit = 10000.0
				case 1:
					self?.stepsLimit = 10_000 * 7
				case 2:
					let calendar = Calendar.current
					let date = Date()

					let range = calendar.range(of: .day, in: .month, for: date)

					let numberOfDaysInMonth = range?.count ?? 30
					self?.stepsLimit = Decimal(10_000 * numberOfDaysInMonth)
				default:
					break
				}
			}
			.store(in: &subscriptions)

		$estimatedRewardPoints
			.sink { _ in

			}
			.store(in: &subscriptions)
	}

	func fetchCheckins() async throws {
		let checkins = try await client.fetchAllCheckinsByUse(fid: 203666, startDate: Date(), endDate: Date())
		self.allWeeksData = checkins.reduce(into: [:]) { _, checkin in
			let date = checkin.createdAt.startOfDay

		}
	}

	func calculateRewardPoints(activity: ActivityData) -> Decimal {
		let maxSteps: Decimal = 10000.0
		let maxCalories: Decimal = 500.0

		let stepBonus: Decimal = activity.steps >= maxSteps ? 1.1 : 1.0
		let calorieBonus: Decimal = activity.caloriesBurned >= maxCalories ? 1.1 : 1.0

		let stepPoints = (activity.steps / maxSteps) * stepWeight * stepBonus
		let caloriePoints = (activity.caloriesBurned / maxCalories) * calorieWeight * calorieBonus

		let distancePoints = (activity.distance) * distanceWeight
		let heartRatePoints = heartRateMultiplier(for: averageHeartRate) * heartRateWeight * 1000

		let basePoints = stepPoints + caloriePoints + distancePoints + heartRatePoints

		return basePoints
	}

	func calculateTotalPoints(startDate: Date, endDate: Date) {
		fetchHealthDataForDateRange(start: startDate, end: endDate) { results in
			let activity = ActivityData(steps: results["steps"] ?? 0,
																	caloriesBurned: results["calories"] ?? 0,
																	distance: results["distance"] ?? 0,
																	avgHeartRate: results["heartRate"] ?? 0)

			let result = self.calculateRewardPoints(activity: activity)

			self.estimatedRewardPoints = result
		}
	}

	func fetchHealthDataForDateRange(start: Date, end: Date, completion: @escaping ([String: Decimal]) -> Void) {
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

			results["heartRate"] = self.averageHeartRate

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
	func requestHealthKitAccess() async throws {
		try await withCheckedThrowingContinuation { continuation in
			healthKitManager.requestAuthorization { [weak self] (success, error) in

				DispatchQueue.main.async {

					if success {
						self?.actions.send(.receiveHealthKitAccess(.success(success))
						)
						continuation.resume()
					} else {
						self?.actions.send(.receiveHealthKitAccess(.error(.noAuthorization))
						)

						if let error = error {
							SentrySDK.capture(error: error)
							continuation.resume(throwing: error)
						} else {
							continuation.resume(throwing: NSError(domain: "HealthKitAuthorization", code: -1, userInfo: [NSLocalizedDescriptionKey: "Authorization failed with unknown error"]))
						}
					}
				}
			}
		}
	}

	// Fetch all required health data (steps, calories, distance, resting heart rate)
	func fetchHealthData() {
		let value: (Date, Date)

		switch filterSelection {
		case 0:
			let startDate = Calendar.current.startOfDay(for: Date())
			var components = DateComponents()
			components.day = 1
			components.second = -1
			let endDate = Calendar.current.date(byAdding: components, to: startDate)!
			value = (startDate, endDate)

		case 1:
			let startOfWeek = Calendar.current.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: Date()).date!
			var components = DateComponents()
			components.weekOfYear = 1
			components.second = -1
			let endOfWeek = Calendar.current.date(byAdding: components, to: startOfWeek)!
			value = (startOfWeek, endOfWeek)

		case 2:
			let components = Calendar.current.dateComponents([.year, .month], from: Date())
			let startOfMonth = Calendar.current.date(from: components)!
			var componentsEnd = DateComponents()
			componentsEnd.month = 1
			componentsEnd.second = -1
			let endOfMonth = Calendar.current.date(byAdding: componentsEnd, to: startOfMonth)!
			value = (startOfMonth, endOfMonth)

		default:
			value = (Date(), Date())
		}

		fetchSteps(startDate: value.0, endDate: value.1)
		fetchCaloriesBurned(startDate: value.0, endDate: value.1)
		fetchDistanceTraveled(startDate: value.0, endDate: value.1)
		fetchRestingHeartRate(startDate: value.0, endDate: value.1)
		fetchAverageHeartRate(startDate: value.0, endDate: value.1)
	}

	// Fetch today's step count
	func fetchSteps(startDate: Date = Date(), endDate: Date = Date()) {
		healthKitManager.getTodayStepCount(startDate: startDate, endDate: endDate) { [weak self] (steps, error) in
			DispatchQueue.main.async {
				if let error {
					self?.steps = 0
					SentrySDK.capture(event: .init(error: MoxieError.message("Error fetching steps \(error)")))
				} else {
					self?.steps = Decimal(steps)
				}
			}
		}
	}

	// Fetch today's calories burned
	func fetchCaloriesBurned(startDate: Date = Date(), endDate: Date = Date()) {
		healthKitManager.fetchCaloriesBurned(startDate: startDate, endDate: endDate) { [weak self] (calories, error) in
			DispatchQueue.main.async {
				if let error = error {
					self?.caloriesBurned = 0
					SentrySDK.capture(event: .init(error: MoxieError.message("Error fetching calories \(error)")))
				} else {
					self?.caloriesBurned = Decimal(calories ?? 0)
				}
			}
		}
	}

	// Fetch today's distance traveled
	func fetchDistanceTraveled(startDate: Date = Date(), endDate: Date = Date()) {
		healthKitManager.fetchDistance(startDate: startDate, endDate: endDate) { [weak self] (distance, error) in
			DispatchQueue.main.async {
				if let error = error {
					self?.distanceTraveled = 0

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
	func fetchRestingHeartRate(startDate: Date = Date(), endDate: Date = Date()) {
		healthKitManager.getRestingHeartRateForMonth(startDate: startDate, endDate: endDate) { [weak self] (heartRate, error) in
			DispatchQueue.main.async {
				if let error = error {
					self?.restingHeartRate = 0

					SentrySDK.capture(error: error)
				} else {
					self?.restingHeartRate = Decimal(heartRate ?? 0)
				}
			}
		}
	}

	func fetchAverageHR(startDate: Date = Date(), endDate: Date = Date()) {
		healthKitManager.getAverageHeartRate(startDate: startDate, endDate: endDate) { [weak self] (heartRate, error) in
			DispatchQueue.main.async {
				if let error = error {
					self?.averageHeartRate = 0

					SentrySDK.capture(error: error)
				} else {
					self?.averageHeartRate = Decimal(heartRate ?? 0)
				}
			}
		}
	}

	func fetchAverageHeartRate(startDate: Date = Date(), endDate: Date = Date()) {
		healthKitManager.fetchAvgHRWorkouts(startDate: startDate, endDate: endDate) { avgHR in
			self.averageHeartRate = Decimal(avgHR ?? 0)

			if self.averageHeartRate == 0 {
				self.fetchAverageHR(startDate: startDate, endDate: endDate)
			}
		}
	}
}

extension StepCountViewModel {
	func changeWeek(by offset: Int) {
		if let newWeekDate = Calendar.current.date(byAdding: .weekOfYear, value: offset, to: currentWeekStartDate.startOfDay()) {
			currentWeekStartDate = newWeekDate
			fetchWeekDataIfNeeded(for: newWeekDate)
		}
	}

	func fetchWeekDataIfNeeded(for weekStartDate: Date) {
		let normalizedDate = weekStartDate.startOfDay()
		if allWeeksData[normalizedDate] == nil {
			allWeeksData[normalizedDate] = generateSampleDays(for: normalizedDate)
		}
	}

	func generateSampleDays(for startDate: Date) -> [Day] {
		(0..<7).compactMap { offset in
			if let date = Calendar.current.date(byAdding: .day, value: offset, to: startDate) {
				let isCheckedIn: Bool?
				if date < Date() {
					isCheckedIn = Bool.random()
				} else {
					isCheckedIn = nil
				}
				return Day(date: date, isCheckedIn: isCheckedIn)
			}
			return nil
		}
	}

	func formattedDate(_ date: Date) -> String {
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		return formatter.string(from: date)
	}
}
