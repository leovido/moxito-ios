import SwiftUI
import MoxitoLib
import MoxieLib

struct ActivityResultsView: View {
	@EnvironmentObject var viewModel: StepCountViewModel

	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 20) {
				Text("Activity results")
					.font(.title)
					.fontWeight(.bold)
					.padding(.leading)

				if viewModel.scores.isEmpty {
					ContentUnavailableView("No activity results yet.", systemImage: "figure.run", description: Text("Check in via frame to participate in fitness rewards every day"))
				} else {
					ForEach(viewModel.scores, id: \.title) { title in
						RoundSection(round: title)
					}
				}
			}
			.padding(.vertical)
		}
	}
}

struct RoundSection: View {
	let round: Round

	var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			HStack {
				Image(systemName: "figure.run")
					.foregroundColor(Color(uiColor: MoxieColor.primary))
				Text("Round \(round.title)")
					.foregroundColor(Color(uiColor: MoxieColor.primary))
					.fontWeight(.semibold)
			}
			.padding(.horizontal)

			VStack(spacing: 0) {
				HStack {
					Text("Time")
						.foregroundColor(.gray)
					Spacer()
					Text("Points")
						.foregroundColor(.gray)
				}
				.padding(.horizontal)
				.padding(.bottom, 8)

				ForEach(round.results, id: \.id) { result in
					HStack {
						Text(result.timestamp.formatted(.dateTime))
							.font(.custom("Inter", size: 15))
						Spacer()
						Text(String(format: "%.2f", result.points))
							.font(.custom("Inter", size: 15))
					}
					.padding(.horizontal)
					.padding(.vertical, 8)
				}
			}
			.background(Color(UIColor.systemBackground))
		}
	}
}

#Preview {
	ActivityResultsView()
		.preferredColorScheme(.light)
}
