import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                HomeView()
            }
            .tabItem {
                Label("Ana Sayfa", systemImage: "house.fill")
            }
            .tag(0)
            
            NavigationView {
                PrayersView()
            }
            .tabItem {
                Label("Namaz", systemImage: "moon.stars.fill")
            }
            .tag(1)
            
            NavigationView {
                GuidesView()
            }
            .tabItem {
                Label("Rehberler", systemImage: "book.fill")
            }
            .tag(2)
            
            NavigationView {
                MapsView()
            }
            .tabItem {
                Label("Camiler", systemImage: "map.fill")
            }
            .tag(3)
            
            NavigationView {
                ProfileView()
            }
            .tabItem {
                Label("Profil", systemImage: "person.fill")
            }
            .tag(4)
        }
        .accentColor(.accentColor)
    }
}

// MARK: - Preview
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
} 