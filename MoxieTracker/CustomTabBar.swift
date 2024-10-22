import SwiftUI
import MoxieLib

enum Tab: String, Hashable, CaseIterable {
	case home = "Home"
	case profile = "Person"
	case search = "magnifyingglass"
	case fitness = "Fitness"
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
						.frame(maxWidth: geo.size.width * 0.25)
					
					TabBarButton(imageName: Tab.fitness.rawValue, tabName: .fitness, selectedTab: $currentTab)
						.frame(width: buttonDimen, height: buttonDimen)
						.onTapGesture {
							currentTab = .fitness
						}
						.frame(maxWidth: geo.size.width * 0.25)
					
					TabBarButtonSearch(imageName: Tab.search.rawValue, tabName: .search, selectedTab: $currentTab)
						.frame(width: buttonDimen, height: buttonDimen)
						.onTapGesture {
							currentTab = .search
						}
						.frame(maxWidth: geo.size.width * 0.25)
					
					TabBarButton(imageName: Tab.profile.rawValue, tabName: .profile, selectedTab: $currentTab)
						.frame(width: buttonDimen, height: buttonDimen)
						.onTapGesture {
							currentTab = .profile
						}
						.frame(maxWidth: geo.size.width * 0.25)
				}
				.frame(maxWidth: geo.size.width)
				.tint(Color.white)
				.padding(.vertical, 12)
				.padding(.bottom, 10)
				.background(Color(uiColor: MoxieColor.primary))
				.clipShape(UnevenRoundedRectangle(cornerRadii: .init(topLeading: 24, topTrailing: 24)))
				.frame(alignment: .bottom)
			}
		}
	}
}

private struct TabBarButtonSearch: View {
	let imageName: String
	let tabName: Tab
	
	@Binding var selectedTab: Tab
	
	var body: some View {
		Image("magnifyingglass")
			.renderingMode(.template)
			.frame(width: 24, height: 24)
			.foregroundStyle(tabName == selectedTab ? Color.white : Color("TabIconColor", bundle: .main))
	}
}

private struct TabBarButton: View {
	let imageName: String
	let tabName: Tab
	
	@Binding var selectedTab: Tab
	
	var body: some View {
		Image(tabName == selectedTab ? "\(imageName)Selected" : "\(imageName)Unselected")
			.renderingMode(.template)
			.frame(width: 24, height: 24)
			.foregroundStyle(tabName == selectedTab ? Color.white : Color("TabIconColor", bundle: .main))
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		CustomBottomTabBarView(currentTab: .constant(.home))
			.ignoresSafeArea()
	}
}
