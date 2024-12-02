//
//  SyncingPointsView.swift
//  fc-poc-wf
//
//  Created by Christian Ray Leovido on 29/11/2024.
//

import SwiftUI
import MoxieLib

public struct SyncingPointsView: View {
	@EnvironmentObject var viewModel: StepCountViewModel

	public init() {}

	public var body: some View {
		VStack {
			Button {
				viewModel.actions.send(.presentScoresView)
			} label: {
				Text("View scores")
					.foregroundStyle(Color.white)
					.padding(.horizontal)
			}
			.padding(8)
			.background(
					Color(uiColor: viewModel.checkins.contains {
							Calendar.current.isDateInToday($0.createdAt)
					} ? MoxieColor.green : MoxieColor.primary)
			)
			.clipShape(RoundedRectangle(cornerRadius: 24))
			.padding(.top, 4)

//			HStack {
//				Text(viewModel.isInSync ? "Synced" : "Syncing...")
//					.foregroundStyle(Color(uiColor: MoxieColor.primary))
//					.padding(.horizontal)
//					.font(.custom("Inter", size: 11))
//
//				Image(systemName: viewModel.isInSync ? "checkmark.circle.fill" : "circle")
//					.foregroundStyle(Color(uiColor: MoxieColor.green))
//			}
		}
	}
}
