import SwiftUI

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        List {
            NavigationLink("Категории") {
                CategoriesSettingsView()
            }
            
            Button("Экспорт данных") {
                do {
                    let service = ExportService(context: modelContext)
                    try service.exportAll()
                } catch {
                    print(error)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
