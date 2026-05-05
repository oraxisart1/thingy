import SwiftUI
import SwiftData

struct MainView: View {
    @Environment(\.modelContext) private var modelContext

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
        .environment(\.appStateProvider, AppStateProvider(context: modelContext))
    }
}

#Preview {
    MainView()
        .modelContainer(PreviewProvider.make(FullDataPreview.self))
}
