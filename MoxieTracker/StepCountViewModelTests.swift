import XCTest
@testable import MoxieTracker
import HealthKit
import MoxitoLib

final class StepCountViewModelTests: XCTestCase {
    var sut: StepCountViewModel!
    var mockHealthKitManager: MockHealthKitManager!
    var mockClient: MockMoxitoClient!

    override func setUp() {
        super.setUp()
        mockHealthKitManager = MockHealthKitManager()
        mockClient = MockMoxitoClient()
        sut = StepCountViewModel(
            healthKitManager: mockHealthKitManager,
            client: mockClient
        )
    }

    override func tearDown() {
        sut = nil
        mockHealthKitManager = nil
        mockClient = nil
        super.tearDown()
    }

    func test_calculateTotalPoints_withValidActivityData_returnsExpectedPoints() async {
        // Given
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)!
        mockHealthKitManager.mockHealthData = [
            "steps": 10000,
            "calories": 500,
            "distance": 8,
            "heartRate": 130
        ]

        // When
        let points = await sut.calculateTotalPoints(startDate: startDate, endDate: endDate)

        // Then
        XCTAssertGreaterThan(points, 0)
        // You may want to add more specific assertions based on your point calculation logic
    }

    func test_calculatePointsAction_syncPointsWithServer() async {
        // Given
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)!
        mockHealthKitManager.mockHealthData = [
            "steps": 10000,
            "calories": 500,
            "distance": 8,
            "heartRate": 130
        ]

        // When
        sut.actions.send(.calculatePoints(startDate: startDate, endDate: endDate))

        // Wait for async operations to complete
        await fulfillment(of: [mockClient.scorePostedExpectation], timeout: 1.0)

        // Then
        XCTAssertTrue(mockClient.didPostScore)
        XCTAssertNotNil(mockClient.lastPostedScore)
    }
}

// MARK: - Mock Classes

class MockHealthKitManager: HealthKitManager {
    var mockHealthData: [String: Double] = [:]

    override func checkNoManualInput(completion: @escaping (Bool) -> Void) {
        completion(false)
    }

    override func getTodayStepCount(startDate: Date, endDate: Date, completion: @escaping (Double, Error?) -> Void) {
        completion(mockHealthData["steps"] ?? 0, nil)
    }
}

class MockMoxitoClient: MoxitoClient {
    var didPostScore = false
    var lastPostedScore: MoxitoScoreModel?
    let scorePostedExpectation = XCTestExpectation(description: "Score posted")

    override func postScore(model: MoxitoScoreModel) async throws -> MoxitoScoreResponse {
        didPostScore = true
        lastPostedScore = model
        scorePostedExpectation.fulfill()
        return MoxitoScoreResponse(success: true)
    }
}
