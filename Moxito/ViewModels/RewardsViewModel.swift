import HealthKit
import SwiftUI
import Combine
import UIKit

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

enum RewardsAction: Hashable {
        case onAppear
        case onDisappear
}

@MainActor
final class RewardsViewModel: ObservableObject, Observable {
        @Published var timeRemaining: TimeInterval = 0

        let actions: PassthroughSubject<RewardsAction, Never> = .init()
        private var subscriptions: Set<AnyCancellable> = []
        private var timer: Timer?

        init() {
                actions
                        .sink { [weak self] action in
                                switch action {
                                case .onAppear:
                                        self?.startTimer()
                                case .onDisappear:
                                        self?.stopTimer()
                                }
                        }
                        .store(in: &subscriptions)
        }

        func openHealthApp() {
                if let url = URL(string: "x-apple-health://") {
                        UIApplication.shared.open(url)
                }
        }

        private func startTimer() {
                updateTimeRemaining()
                timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                        self?.updateTimeRemaining()
                }
        }

        private func stopTimer() {
                timer?.invalidate()
                timer = nil
        }

        private func updateTimeRemaining() {
                let calendar = Calendar.current
                let now = Date()
                let utcCalendar = Calendar(identifier: .gregorian)
                var components = DateComponents()
                components.timeZone = TimeZone(identifier: "UTC")
                components.hour = 0
                components.minute = 0
                components.second = 0

                guard let nextDeadline = utcCalendar.nextDate(after: now, matching: components, matchingPolicy: .nextTime) else {
                        return
                }

                timeRemaining = nextDeadline.timeIntervalSince(now)
        }
}
