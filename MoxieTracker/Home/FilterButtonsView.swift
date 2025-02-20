import SwiftUI
import MoxieLib

struct FilterButtonsView: View {
	@Binding var filterSelection: Int
	
	var body: some View {
		HStack {
			Spacer()
			
			ForEach(0..<3) { index in
				Button {
					filterSelection = index
				} label: {
					Text(index == 0 ? "Daily" : index == 1 ? "Weekly" : "Lifetime")
						.foregroundStyle(filterSelection == index ? Color.white : Color(uiColor: MoxieColor.grayPickerText))
						.font(.custom("Inter", size: 14))
				}
				.frame(width: 100)
				.padding(4)
				.background(filterSelection == index ? Color(uiColor: MoxieColor.green) : .clear)
				.clipShape(Capsule())
				
				Spacer()
			}
		}
		.padding(.vertical, 6)
		.background(Color.white)
		.clipShape(Capsule())
		.frame(height: 40)
	}
}
