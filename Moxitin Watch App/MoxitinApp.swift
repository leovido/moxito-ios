//
//  MoxitinApp.swift
//  Moxitin Watch App
//
//  Created by Christian Ray Leovido on 12/09/2024.
//

import SwiftUI
import MoxieLib

@main
struct Moxitin_Watch_AppApp: App {
	@State private var entry: SimpleEntry = .init(date: .now, dailyMoxie: 2039409, dailyUSD: 394, claimableMoxie: 30493, claimableUSD: 39402934, claimedMoxie: 4930293)
    var body: some Scene {
        WindowGroup {
					ContentView(entry: entry)
						.onAppear {
							do {
								var moxieModel: MoxieModel = .noop

								if let userDefaults = UserDefaults(suiteName: "group.com.christianleovido.moxito"),
									 let data = userDefaults.data(forKey: "moxieData"),
									 let decodedModel = try? CustomDecoderAndEncoder.decoder.decode(
										MoxieModel.self,
										from: data
									 ) {
									moxieModel = decodedModel
								}
								
//								let price = try await configuration.client.fetchPrice()
								
								self.entry = SimpleEntry(date: .now,
																							dailyMoxie: moxieModel.allEarningsAmount,
																				dailyUSD:  moxieModel.allEarningsAmount,
																				claimableMoxie: moxieModel.moxieClaimTotals.first!.availableClaimAmount,
																				claimableUSD: moxieModel.moxieClaimTotals.first!.availableClaimAmount,
																				claimedMoxie: moxieModel.moxieClaimTotals.first!.claimedAmount)
								
							} catch {
								dump(error)
							}
						}
        }
    }
		
}
