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
	case fetchLatestRound
	case receiveLatestRound(Result<MoxitoRound, HealthKitError>)
	case receiveHealthKitAccess(Result<Bool, HealthKitError>)
	case checkFIDPoints
	case onAppear(fid: Int)
	case requestAuthorizationHealthKit
	case calculatePoints(startDate: Date, endDate: Date)
	case syncPoints(Decimal)
	case presentScoresView
	case fetchScores
	case receiveScores(Result<[Round], HealthKitError>)
	case fetchTotalUsersCountCheckins
}

@MainActor
final class StepCountViewModel: ObservableObject, Observable {
	static let shared = StepCountViewModel()
	let healthKitManager: HealthKitService

	@Published var totalUsersCheckedInCount: Int = 0
	@Published var scores: [Round] = []
	@Published var stepsTodayText: String = "Steps today"
	@Published var checkins: [MoxitoCheckinModel] = []
	@Published var currentRound: MoxitoRound?
	@Published var fid: Int = 0
	@Published var steps: Decimal = 0.0
	@Published var caloriesBurned: Decimal = 0.0
	@Published var distanceTraveled: Decimal = 0.0
	@Published var restingHeartRate: Decimal = 0.0
	@Published var averageHeartRate: Decimal = 0.0
	@Published var estimatedRewardPoints: Decimal = 0.0
	@Published var didAuthorizeHealthKit: Bool = false
	@Published var isSyncingData: Bool = false
	@Published var isInSync: Bool = false
	@Published var isScoresViewVisible: Bool = false
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

	init(healthKitManager: HealthKitService = HealthKitService(), steps: Decimal = 0, caloriesBurned: Decimal = 0, distanceTraveled: Decimal = 0, restingHeartRate: Decimal = 0, didAuthorizeHealthKit: Bool = false,
			 client: MoxitoClient = .init()) {
		self.healthKitManager = healthKitManager
		self.steps = steps
		self.caloriesBurned = caloriesBurned
		self.distanceTraveled = distanceTraveled
		self.restingHeartRate = restingHeartRate
		self.didAuthorizeHealthKit = didAuthorizeHealthKit
		self.client = client
		self.currentRound = currentRound

		$checkins
			.removeDuplicates()
			.filter { !$0.isEmpty }
			.sink { [weak self] newValues in
				guard let self else {
					return
				}
				Task {
					self.isSyncingData = true
					await withTaskGroup(of: Void.self) { group in
						for model in newValues {
							group.addTask {
								do {
									let endDate = await self.endOfDay(for: model.createdAt) ?? Date()
									let points = await self.calculateTotalPoints(startDate: model.createdAt, endDate: endDate)

									_ = try await client.postScore(
										model: .init(
											score: points,
											fid: self.fid,
											checkInDate: model.createdAt,
											weightFactorId: "0dd3ab92-d855-4975-a2c4-acb74462305b"
										),
										roundId: self.currentRound?.roundId ?? "")
								} catch {
									SentrySDK.capture(error: error)
								}
							}
						}
					}
					self.isInSync = true
					self.isSyncingData = false
					self.actions.send(.fetchScores)
				}
			}
			.store(in: &subscriptions)

		let sharedPublisher = actions.share()

		sharedPublisher.sink { [weak self] action in
			guard let self else {
				return
			}
			switch action {
			case .fetchLatestRound:
				Task {
					let latestRound = try await self.client.fetchLatestRound()
					self.actions.send(.receiveLatestRound(.success(latestRound)))
				}
			case .receiveLatestRound(.success(let round)):
				self.currentRound = round
			case .receiveLatestRound(.error(let error)):
				self.currentRound = nil
			case .fetchScores:
				Task {
					let allScores = try await self.client.fetchAllScores(fid: self.fid)

					self.actions.send(.receiveScores(.success(allScores.rounds)))
				}
			case .fetchTotalUsersCountCheckins:
				Task {
					let count = try await self.client.fetchAllCheckinsByUse(fid: nil, startDate: Calendar.current.startOfDay(for: Date()), endDate: Date()).count
					self.totalUsersCheckedInCount = count
				}
			case .receiveScores(.success(let scores)):
				self.scores = scores
			case .receiveScores(.error(let error)):
				self.scores = []
			case .presentScoresView:
				self.isScoresViewVisible = true
			case .requestAuthorizationHealthKit:
				Task {
					try await self.requestHealthKitAccess()
				}
			case .fetchHealthData:
				self.fetchHealthData()
			case .onAppear(let fid):
				self.fid = fid
				Task {
					do {
						let scores = try await self.client.fetchAllScores(fid: fid)
						self.actions.send(.receiveScores(.success(scores.rounds)))
						try await self.fetchCheckins(fid: fid)
					} catch {
						SentrySDK.capture(error: error)
					}
				}

				return
			case .calculatePoints(let startDate, let endDate):
				let hasCheckinToday = checkins.contains { checkin in
					Calendar.current.isDate(checkin.createdAt, inSameDayAs: Date())
				}
				Task {
					let round = try await self.client.fetchLatestRound()
					self.currentRound = round
					let points =  await self.calculateTotalPoints(startDate: startDate, endDate: endDate)

					self.estimatedRewardPoints = points

					self.actions.send(.syncPoints(points))
				}
			case .checkFIDPoints:
				return
			case .receiveHealthKitAccess(.success(let isSuccess)):
				self.didAuthorizeHealthKit = isSuccess

				self.actions.send(.fetchHealthData)
			case .receiveHealthKitAccess(.error(let error)):
				self.didAuthorizeHealthKit = false

				SentrySDK.capture(error: error)

			case .syncPoints(let score):
				Task {
					do {
						// Ensure we have the current round
						let round = try await self.client.fetchLatestRound()
						let model = MoxitoScoreModel(score: score,
																			 fid: self.fid,
																			 checkInDate: Date(),
																			 weightFactorId: "97ed5eff-d2c6-4696-884d-dc5dbe36f27a")
						_ = try await self.client.postScore(model: model, roundId: round.roundId)
					} catch {
						SentrySDK.capture(error: error)
					}
				}
			}
		}
		.store(in: &subscriptions)

		$filterSelection
			.sink { [weak self] newSelection in
				switch newSelection {
				case 0:
					self?.stepsLimit = 10000.0
					self?.stepsTodayText = "Steps today"
				case 1:
					self?.stepsLimit = 10_000 * 7
					self?.stepsTodayText = "Steps this week"
				case 2:
					let calendar = Calendar.current
					let date = Date()

					let range = calendar.range(of: .day, in: .month, for: date)

					let numberOfDaysInMonth = range?.count ?? 30
					self?.stepsLimit = Decimal(10_000 * numberOfDaysInMonth)
					self?.stepsTodayText = "Steps this month"
				default:
					break
				}
			}
			.store(in: &subscriptions)
	}

	func getStartAndEndOfCurrentWeek() -> (startOfWeek: Date?, endOfWeek: Date?) {
		let calendar = Calendar.current
		let today = Date()

		// Get the start of the current week
		guard let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: today)?.start else {
			return (nil, nil)
		}

		// Calculate the end of the current week by adding 6 days to the start of the week
		let endOfWeek = calendar.date(byAdding: .day, value: 7, to: startOfWeek)

		return (startOfWeek, endOfWeek)
	}

	func endOfDay(for date: Date) -> Date? {
		let calendar = Calendar.current
		var components = DateComponents()
		components.hour = 23
		components.minute = 59
		components.second = 59
		return calendar.date(bySettingHour: components.hour!,
												 minute: components.minute!,
												 second: components.second!,
												 of: date)
	}

	func fetchTotalUsersCountCheckins() async throws {
		let count = try await client.fetchAllCheckinsByUse(
			fid: nil,
			startDate: Calendar.current.startOfDay(for: Date()),
			endDate: Date()
		).count

		totalUsersCheckedInCount = count
	}

	func fetchCheckins(fid: Int) async throws {
		let (startOfWeek, endOfWeek) = getStartAndEndOfCurrentWeek()
		let checkins = try await client.fetchAllCheckinsByUse(fid: fid, startDate: startOfWeek ?? Date(), endDate: endOfWeek ?? Date())

		self.checkins = checkins
		self.allWeeksData = checkins.reduce(into: [:]) { result, checkin in
			let date = checkin.createdAt.startOfDay()

			result[date] = [.init(date: date, isCheckedIn: true)]
		}
	}

	func calculateRewardPoints(activity: ActivityData) -> Decimal {
		let maxSteps: Double = 10000.0
		let maxCalories: Double = 500.0

		// Bonus scaling for steps
		let stepBonus = calculateBonus(for: activity.steps, thresholds: [10000, 12500, 15000, 20000])
		// Bonus scaling for calories burned
		let calorieBonus = calculateBonus(for: activity.caloriesBurned, thresholds: [500, 700, 900, 1200])

		// Apply step bonus and weight
		let stepPoints = (activity.steps / maxSteps) * stepWeight * stepBonus
		// Apply calorie bonus and weight
		let caloriePoints = (activity.caloriesBurned / maxCalories) * calorieWeight * calorieBonus

		// Weighted points for distance traveled
		let distancePoints = (activity.distance) * distanceWeight

		// Adjusted heart rate points using logarithmic scaling
		let heartRatePoints = logHeartRateMultiplier(for: activity.avgHeartRate) * heartRateWeight * 1000

		// Calculate total points with updated weights and scaling
		let basePoints = stepPoints + caloriePoints + distancePoints + heartRatePoints

		// Cap points if necessary to align with token pool distribution
		return Decimal(min(basePoints, 20000)) // Assuming 20,000 as a daily cap for sustainable distribution
	}

	// Helper function for incremental bonuses
	func calculateBonus(for value: Double, thresholds: [Double]) -> Double {
		for (index, threshold) in thresholds.enumerated().reversed() {
			if value >= threshold {
				return 1.1 + (Double(index)) * 0.1
			}
		}
		return 1.0
	}

	// Logarithmic heart rate multiplier for balanced scoring
	func logHeartRateMultiplier(for avgHeartRate: Double) -> Double {
		switch avgHeartRate {
		case 90..<110: return log2(1.2)
		case 110..<130: return log2(1.3)
		case 130..<150: return log2(1.5)
		case 150..<170: return log2(1.7)
		case 170..<200: return log2(2.0)
		default: return log2(1.1)
		}
	}

	func calculateTotalPoints(startDate: Date, endDate: Date) async -> Decimal {
		let results = await fetchHealthDataForDateRange(start: startDate, end: endDate)

		let activity = ActivityData(
			steps: results["steps"] ?? 0,
			caloriesBurned: results["calories"] ?? 0,
			distance: results["distance"] ?? 0,
			avgHeartRate: results["heartRate"] ?? 0
		)

		let result = calculateRewardPoints(activity: activity)
		return result
	}

	func fetchHealthDataForDateRange(start: Date, end: Date) async -> [String: Double] {
		await withCheckedContinuation { continuation in
			fetchHealthDataForDateRange(start: start, end: end) { results in
				continuation.resume(returning: results)
			}
		}
	}

	func fetchHealthDataForDateRange(start: Date, end: Date, completion: @escaping ([String: Double]) -> Void) {
		let group = DispatchGroup()
		var isCompleted = false

		healthKitManager.checkNoManualInput { isManualInput in
			guard !isManualInput else {
				if !isCompleted {
					isCompleted = true
					completion(["steps": 0, "calories": 0, "distance": 0, "heartRate": 0])
				}
				return
			}

			let healthStore = HKHealthStore()
			let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)

			let stepQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
			let calorieQuantityType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
			let distanceQuantityType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!

			var results: [String: Double] = ["steps": 0, "calories": 0, "distance": 0, "heartRate": 0]

			// Steps Query
			group.enter()
			let stepQuery = HKStatisticsQuery(quantityType: stepQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
				if let sum = result?.sumQuantity() {
					results["steps"] = sum.doubleValue(for: HKUnit.count())
				}
				group.leave()
			}
			healthStore.execute(stepQuery)

			// Calories Query
			group.enter()
			let calorieQuery = HKStatisticsQuery(quantityType: calorieQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
				if let sum = result?.sumQuantity() {
					results["calories"] = sum.doubleValue(for: HKUnit.kilocalorie())
				}
				group.leave()
			}
			healthStore.execute(calorieQuery)

			// Distance Query
			group.enter()
			let distanceQuery = HKStatisticsQuery(quantityType: distanceQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
				if let sum = result?.sumQuantity() {
					results["distance"] = sum.doubleValue(for: HKUnit.meter()) / 1000
				}
				group.leave()
			}
			healthStore.execute(distanceQuery)

			results["heartRate"] = Double(truncating: self.averageHeartRate as NSNumber)

			group.notify(queue: .main) {
				if !isCompleted {
					isCompleted = true
					completion(results)
				}
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
		let calendar = Calendar.current

		switch filterSelection {
		case 0: // Today
			let startDate = calendar.startOfDay(for: Date())
			var components = DateComponents()
			components.day = 1
			components.second = -1
			let endDate = calendar.date(byAdding: components, to: startDate)!
			value = (startDate, endDate)

		case 1: // This week
			let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
			var components = DateComponents()
			components.day = 7
			let endOfWeek = calendar.date(byAdding: components, to: startOfWeek)!
			value = (startOfWeek, endOfWeek)

		case 2: // This month
			let endDate = calendar.startOfDay(for: Date()) // Today
			let startDate = calendar.date(byAdding: .day, value: -30, to: endDate)!
			value = (startDate, endDate)

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
		}
	}

	func formattedDate(_ date: Date) -> String {
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		return formatter.string(from: date)
	}
}
