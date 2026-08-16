import SwiftUI
import SwiftData

struct ArchiveView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [
        SortDescriptor(\Item.name)
    ]) private var allItems: [Item]

    @State private var searchText = ""

    private var archivedItems: [Item] {
        allItems.filter { $0.isArchived && (searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText)) }
    }

    var body: some View {
        List {
            ForEach(archivedItems) { item in
                HStack {
                    Text(item.name)
                        .font(.headline)

                    Spacer()

                    Text(Weight(item.weight).formatted)
                        .font(.subheadline)
                        .foregroundStyle(item.weight > 0 ? Color.secondary : Color.red)
                }
                .padding(.vertical, 4)
                .contentShape(Rectangle())
                .contextMenu {
                    Button("Разархивировать") {
                        _ = item.unarchive()
                    }
                }
            }
        }
        .navigationTitle("Архив")
        .searchable(text: $searchText)
        .overlay {
            if archivedItems.isEmpty {
                ContentUnavailableView("Архив пуст", systemImage: "tray", description: Text("Здесь будут отображаться архивированные вещи"))
            }
        }
    }
}

#Preview("Есть архивные вещи") {
    NavigationStack{
        ArchiveView()
    }
    .modelContainer(PreviewProvider.make(FullDataPreview.self))
}

#Preview("Пусто") {
    NavigationStack{
        ArchiveView()
    }
}
