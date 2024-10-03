import SwiftUI

struct ErrorView: View {
	@Binding var error: Error?

	var body: some View {
		if let error = error {
			VStack {
				Text(error.localizedDescription)
					.bold()
				HStack {
					Button("Dismiss") {
						self.error = nil
					}
				}
			}
			.padding()
			.background(Color.red)
			.foregroundColor(.white)
			.cornerRadius(10)
		}
	}
}
