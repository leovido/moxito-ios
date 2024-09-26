import XCTest
@testable import Moxito
import MoxieLib

final class ClaimTests: XCTestCase {
	func testClaimModel() throws {
		let data = claimJson.data(using: .utf8)!
		let model = try CustomDecoderAndEncoder.decoder.decode(MoxieClaimModel.self, from: data)
		XCTAssertEqual(model, model)
	}
	
	func testClaimFailModel() throws {
		let data = claimFailJson.data(using: .utf8)!
		
		
		let model = try CustomDecoderAndEncoder.decoder.decode(MoxieClaimModel.self, from: data)
		XCTAssertEqual(model.transactionStatus, "")
	}
	
	func testClaimStatusModel() throws {
		let data = claimStatus.data(using: .utf8)!
		let model = try CustomDecoderAndEncoder.decoder.decode(MoxieClaimStatus.self, from: data)
		XCTAssertEqual(model.transactionAmount, 0)
	}
}

let claimStatus = """
{
	"transactionId": null,
	"transactionStatus": "",
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
 "transactionStatus": "",
 "transactionAmount": 1206.299242863659,
 "transactionAmountInWei": "1206299242863658974356",
 "rewardsLastEarnedTimestamp": "2024-08-15T00:00:00.000Z"
}
"""
