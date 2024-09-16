//
//  ContentView.swift
//  Moxitin Watch App
//
//  Created by Christian Ray Leovido on 12/09/2024.
//

import SwiftUI
import MoxieLib

struct SimpleEntry {
	let date: Date
	var dailyMoxie: Decimal
	var dailyUSD: Decimal
	var claimableMoxie: Decimal
	var claimableUSD: Decimal
	var claimedMoxie: Decimal
}

struct ContentView: View {
	var entry: SimpleEntry
	
	var body: some View {
			VStack(alignment: .leading) {
				HStack {
					VStack(alignment: .leading) {
						Text("Daily Ⓜ️")
							.foregroundStyle(Color(uiColor: MoxieColor.textColor))
							.fontDesign(.rounded)
							.fontWeight(.black)
						
						Text(entry.dailyMoxie.formatted(.number.precision(.fractionLength(2))))
							.foregroundStyle(Color(uiColor: MoxieColor.dark))
							.fontWeight(.heavy)
							.fontDesign(.rounded)
						Text("$\(entry.dailyUSD.formatted(.number.precision(.fractionLength(2))))")
							.foregroundStyle(Color(uiColor: MoxieColor.dark))
							.font(.caption)
							.fontWeight(.light)
							.fontDesign(.rounded)
							.padding(.bottom, 4)

						Text("Claimable Ⓜ️")
							.foregroundStyle(Color(uiColor: MoxieColor.textColor))
							.fontDesign(.rounded)
							.fontWeight(.black)
						
						Text(entry.claimableMoxie.formatted(.number.precision(.fractionLength(2))))
							.foregroundStyle(Color(uiColor: MoxieColor.dark))
							.fontWeight(.heavy)
							.fontDesign(.rounded)
						Text("$\(entry.claimableUSD.formatted(.number.precision(.fractionLength(2))))")
							.foregroundStyle(Color(uiColor: MoxieColor.dark))
							.font(.caption)
							.fontWeight(.light)
							.fontDesign(.rounded)
						
						Spacer()
					}
					
					Spacer()
				}
			}
	}
}


#Preview {
	ContentView(entry: .init(date: .now, dailyMoxie: 1000, dailyUSD: 1000, claimableMoxie: 100000, claimableUSD: 10, claimedMoxie: 12323))
}
