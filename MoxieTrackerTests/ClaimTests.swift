import XCTest
@testable import Moxito
import MoxieLib

@MainActor
final class ClaimTests: XCTestCase {
	var vm: MoxieClaimViewModel!
	
	override func tearDown() async throws {
		vm = nil
	}
	
	func testStringShortening() {
		vm = .init()
		vm.selectedWallet = "0x0000000000000001234"
		XCTAssertEqual(vm.selectedWalletDisplay, "\(vm.selectedWallet.prefix(4))...\(vm.selectedWallet.suffix(4))")
	}
	
	func testLoading() async throws {
		vm = .init(moxieClaimStatus: nil, moxieClaimModel: .placeholder, client: MockMoxieClient())

		XCTAssertEqual(vm.isLoading, false)
		
		vm.moxieClaimStatus = .init(transactionID: UUID().uuidString,
																transactionStatus: .REQUESTED,
																transactionHash: nil,
																transactionAmount: 1000,
																transactionAmountInWei: "",
																rewardsLastEarnedTimestamp: .now)
		
		await vm.inFlightTasks[RequestType.checkClaimStatus.rawValue]?.value
		
		XCTAssertEqual(vm.moxieClaimStatus?.transactionStatus, .REQUESTED)
		XCTAssertEqual(vm.inFlightTasks[RequestType.checkClaimStatus.rawValue], nil)
		XCTAssertEqual(vm.isLoading, false)
		XCTAssertNotNil(vm.moxieClaimModel)
		
		vm.moxieClaimStatus = .init(transactionID: UUID().uuidString,
																transactionStatus: nil,
																transactionHash: nil,
																transactionAmount: 1000,
																transactionAmountInWei: "",
																rewardsLastEarnedTimestamp: .now)
		
		XCTAssertEqual(vm.isLoading, false)

		vm.moxieClaimStatus = .init(transactionID: UUID().uuidString,
																transactionStatus: .SUCCESS,
																transactionHash: nil,
																transactionAmount: 1000,
																transactionAmountInWei: "",
																rewardsLastEarnedTimestamp: .now)
		
		XCTAssertEqual(vm.isLoading, false)
	}
	
	// - MARK: Claim tests
	func testClaimModel() throws {
		let data = claimJson.data(using: .utf8)!
		let model = try CustomDecoderAndEncoder.decoder.decode(MoxieClaimModel.self, from: data)
		XCTAssertEqual(model, model)
	}
	
	func testClaimFailModel() throws {
		let data = claimFailJson.data(using: .utf8)!
		
		
		let model = try CustomDecoderAndEncoder.decoder.decode(MoxieClaimModel.self, from: data)
		XCTAssertEqual(model.transactionStatus, "SUCCESS")
	}
	
	func testClaimSuccess() async throws {
		vm = .init(moxieClaimStatus: nil, client: MockMoxieClient())

		vm.actions.send(.claimRewards(""))
		
		await vm.inFlightTasks[RequestType.claimRewards.rawValue]?.value

		XCTAssertEqual(vm.moxieClaimStatus?.transactionStatus, nil)
		XCTAssertEqual(vm.isLoading, false)
		XCTAssertNil(vm.isError)
		XCTAssertEqual(vm.inFlightTasks[RequestType.claimRewards.rawValue], nil)
	}
	
	func testClaimError() async throws {
		vm = .init(moxieClaimStatus: nil, client: MockFailMoxieClient())

		vm.actions.send(.claimRewards(""))
		
		await vm.inFlightTasks[RequestType.claimRewards.rawValue]?.value

		XCTAssertEqual(vm.moxieClaimStatus?.transactionStatus, nil)
		XCTAssertEqual(vm.isLoading, false)
		XCTAssertEqual(vm.isError?.localizedDescription, "Invalid")
		XCTAssertEqual(vm.inFlightTasks[RequestType.claimRewards.rawValue], nil)
	}
	
	// - MARK: Claim status tests
	func testClaimStatusSuccess() async throws {
		vm = .init(moxieClaimStatus: nil, client: MockMoxieClient())

		vm.actions.send(.checkClaimStatus(transactionId: UUID().uuidString))
		
		await vm.inFlightTasks[RequestType.checkClaimStatus.rawValue]?.value
		
		XCTAssertEqual(vm.moxieClaimStatus?.transactionStatus, .REQUESTED)
		XCTAssertEqual(vm.isLoading, true)
		XCTAssertNil(vm.isError)
		XCTAssertEqual(vm.inFlightTasks[RequestType.claimRewards.rawValue], nil)
	}
	
	func testClaimStatusError() async throws {
		vm = .init(moxieClaimStatus: nil, client: MockFailMoxieClient())

		vm.actions.send(.checkClaimStatus(transactionId: UUID().uuidString))

		await vm.inFlightTasks[RequestType.checkClaimStatus.rawValue]?.value
		
		XCTAssertEqual(vm.moxieClaimStatus?.transactionStatus, nil)
		XCTAssertEqual(vm.isLoading, false)
		XCTAssertEqual(vm.isError?.localizedDescription, "Invalid")
		XCTAssertEqual(vm.inFlightTasks[RequestType.claimRewards.rawValue], nil)
	}
	
	func testClaimStatusModel() throws {
		let data = claimStatus.data(using: .utf8)!
		let model = try CustomDecoderAndEncoder.decoder.decode(MoxieClaimStatus.self, from: data)
		XCTAssertEqual(model.transactionAmount, 0)
	}
	
	func testInitiateClaim() async throws {
		vm = .init(moxieClaimStatus: nil, client: MockMoxieClient())

		vm.actions.send(.initiateClaim)
		
		XCTAssertTrue(vm.isClaimAlertShowing)
	}
	
	func testDismissClaimAlert() async throws {
		vm = .init(moxieClaimStatus: nil, client: MockMoxieClient())

		vm.isClaimAlertShowing = true
		vm.actions.send(.dismissClaimAlert)
		
		XCTAssertFalse(vm.isClaimAlertShowing)
	}
}

let claimStatus = """
{
	"transactionId": null,
	"transactionStatus": "REQUESTED",
	"transactionHash": null,
	"transactionAmount": 0,
	"transactionAmountInWei": "0",
	"rewardsLastEarnedTimestamp": "2024-09-24T06:06:07.000Z"
}
"""

let claimJson = """
{
 "fid": "15971",
 "availableClaimAmount": 0,
 "minimumClaimableAmountInWei": "1000000000000000000",
 "availableClaimAmountInWei": "0",
 "claimedAmount": 0,
 "claimedAmountInWei": "0",
 "processingAmount": 1206.299242863659,
 "processingAmountInWei": "1206299242863658974356",
 "tokenAddress": "0x8C9037D1Ef5c6D1f6816278C7AAF5491d24CD527",
 "chainId": 8453,
 "transactionId": "0d9b17b2-07e2-41cb-8cf6-f8351ec7f669",
 "transactionHash": "0x30e12445cc1375f544f99486d36fd144038007488e36f83ed90a2b79950dd66e",
 "transactionStatus": "REQUESTED",
 "transactionAmount": 1206.299242863659,
 "transactionAmountInWei": "1206299242863658974356",
 "rewardsLastEarnedTimestamp": "2024-08-15T00:00:00.000Z"
}
"""

let claimFailJson = """
{
 "fid": "15971",
 "availableClaimAmount": 0,
 "minimumClaimableAmountInWei": "1000000000000000000",
 "availableClaimAmountInWei": "0",
 "claimedAmount": 0,
 "claimedAmountInWei": "0",
 "processingAmount": 1206.299242863659,
 "processingAmountInWei": "1206299242863658974356",
 "tokenAddress": "0x8C9037D1Ef5c6D1f6816278C7AAF5491d24CD527",
 "chainId": 8453,
 "transactionId": "0d9b17b2-07e2-41cb-8cf6-f8351ec7f669",
 "transactionHash": "0x30e12445cc1375f544f99486d36fd144038007488e36f83ed90a2b79950dd66e",
 "transactionStatus": "SUCCESS",
 "transactionAmount": 1206.299242863659,
 "transactionAmountInWei": "1206299242863658974356",
 "rewardsLastEarnedTimestamp": "2024-08-15T00:00:00.000Z"
}
"""
