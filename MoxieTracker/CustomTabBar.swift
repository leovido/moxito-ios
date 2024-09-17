import SwiftUI
import MoxieLib

enum Tab: String, Hashable, CaseIterable {
	case home = "Home"
	case profile = "Person"
}

private let buttonDimen: CGFloat = 55

struct CustomBottomTabBarView: View {
	@Binding var currentTab: Tab
	
	var body: some View {
		GeometryReader { geo in
			VStack {
				Spacer()
				HStack {
					TabBarButton(imageName: Tab.home.rawValue, tabName: .home, selectedTab: $currentTab)
						.frame(width: buttonDimen, height: buttonDimen)
						.onTapGesture {
							currentTab = .home
						}
						.frame(maxWidth: geo.size.width * 0.5)
					
					TabBarButton(imageName: Tab.profile.rawValue, tabName: .profile, selectedTab: $currentTab)
						.frame(width: buttonDimen, height: buttonDimen)
						.onTapGesture {
							currentTab = .profile
						}
						.frame(maxWidth: geo.size.width * 0.5)
				}
				.frame(maxWidth: geo.size.width)
				.tint(Color.white)
				.padding(.vertical, 8)
				.padding(.bottom, 10)
				.background(Color(uiColor: MoxieColor.primary))
				.clipShape(UnevenRoundedRectangle(cornerRadii: .init(topLeading: 20, topTrailing: 20)))
				.frame(alignment: .bottom)
			}
		}
	}
}

private struct TabBarButton: View {
	let imageName: String
	let tabName: Tab
	
	@Binding var selectedTab: Tab
	
	var body: some View {
		Image(tabName == selectedTab ? "\(imageName)Selected" : "\(imageName)Unselected")
			.renderingMode(.original)
			.frame(width: 24, height: 24)
			.tint(tabName == selectedTab ? Color.white : Color("OnboardingText", bundle: .main))
			.fontWeight(.bold)
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		CustomBottomTabBarView(currentTab: .constant(.home))
			.ignoresSafeArea()
	}
}
