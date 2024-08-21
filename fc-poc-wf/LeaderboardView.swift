//
//  LeaderboardView.swift
//  fc-poc-wf
//
//  Created by Christian Ray Leovido on 21/08/2024.
//

import SwiftUI

struct LeaderboardView: View {
	var body: some View {
		FCard(model: .placeholder, willRedact: .placeholder)
		FCard(model: .placeholder, willRedact: .privacy)
			FCard(model: .placeholder, willRedact: [])
			FCard(model: .placeholder, willRedact: [])
			FCard(model: .placeholder, willRedact: [])
			FCard(model: .placeholder, willRedact: [])
	}
}

#Preview {
		LeaderboardView()
}
