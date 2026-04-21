import SwiftUI
import SwiftData

struct MainView: View {
    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
            }.tabItem {
                Image(systemName: "house")
                Text("Главная")
            }
            NavigationStack {
                SettingsView()
            }.tabItem {
                Image(systemName: "gear")
                Text("Настройки")
            }
        }
    }
}

#Preview {
    MainView()
        .modelContainer(for: ItemModel.self, inMemory: true)
        .modelContainer(for: CategoryModel.self, inMemory: true)
}
