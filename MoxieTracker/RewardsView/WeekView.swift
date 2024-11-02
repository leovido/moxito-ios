import SwiftUI
import MoxieLib

struct Day: Hashable, Identifiable {
	let id = UUID()
	var date: Date
	var isCheckedIn: Bool?
}

struct WeekView: View {
	@Binding var days: [Day]

	var body: some View {
		HStack(spacing: 10) {
			ForEach(days) { day in
				Circle()
					.fill(circleColor(for: day))
					.frame(width: 40, height: 40)
					.overlay(
						Text("\(Calendar.current.component(.day, from: day.date))")
							.foregroundColor(.black)
							.font(.custom("Inter", size: 18))
							.bold()
					)
			}
		}
	}

	private func circleColor(for day: Day) -> Color {
		switch day.isCheckedIn {
		case .some(true): return Color(uiColor: MoxieColor.green)
		case .some(false): return Color(uiColor: .systemGray6)
		default: return .white
		}
	}
}

struct SwipeableWeekView: View {
	@EnvironmentObject var viewModel: StepCountViewModel

	var body: some View {
		VStack {
			// Fetch weekDays only if available
			if let weekDays = viewModel.allWeeksData[viewModel.currentWeekStartDate.startOfDay()] {
				WeekView(days: Binding(get: { weekDays }, set: { viewModel.allWeeksData[viewModel.currentWeekStartDate.startOfDay()] = $0 }))
					.padding(.horizontal)
					.gesture(
						DragGesture()
							.onEnded { value in
								if value.translation.width < 0 { // Swipe left
									viewModel.changeWeek(by: 1)
								} else if value.translation.width > 0 { // Swipe right
									viewModel.changeWeek(by: -1)
								}
							}
					)
			} else {
				Text("Loading...")
					.padding()
					.onAppear {
						// Populate the current and nearby weeks if not already done
						viewModel.fetchWeekDataIfNeeded(for: viewModel.currentWeekStartDate)
					}
			}
		}
	}
}

extension Date {
	func startOfDay() -> Date {
		return Calendar.current.startOfDay(for: self)
	}
}

extension Calendar {
	func nextMonday(for date: Date) -> Date {
		let components = dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
		let startOfWeek = self.date(from: components) ?? date
		let mondayOffset = (self.firstWeekday == 2) ? 0 : (2 - self.component(.weekday, from: startOfWeek) + 7) % 7
		return self.date(byAdding: .day, value: mondayOffset, to: startOfWeek) ?? startOfWeek
	}
}
