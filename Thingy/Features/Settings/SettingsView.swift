import SwiftUI

struct SettingsView: View {
    var body: some View {
        List {
            NavigationLink("Категории") {
                CategoriesSettingsView()
            }
        }
    }
}

#Preview {
    SettingsView()
}
