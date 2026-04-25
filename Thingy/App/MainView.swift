import SwiftUI
import SwiftData

struct MainView: View {
    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Image(systemName: "house")
                Text("Главная")
            }
            
            NavigationStack {
                TripView()
            }
            .tabItem {
                Image(systemName: "suitcase")
                Text("Поездка")
            }
            
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Image(systemName: "gear")
                Text("Настройки")
            }
        }
    }
}

#Preview {
    MainView()
        .modelContainer(for: Item.self, inMemory: true)
        .modelContainer(for: Category.self, inMemory: true)
}
