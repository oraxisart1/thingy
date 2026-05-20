import SwiftUI
import SwiftData

struct ItemPicker: View {
    @Environment(\.dismiss) private var dismiss
    
    @Query(sort: [
        SortDescriptor(\Item.name)
    ]) private var items: [Item]
    
    @State private var searchText: String = ""
    @State private var selectedItems: Set<Item> = []
    
    let title: String
    let filter: (Item) -> Bool
    let onDone: ([Item]) -> Void
    let noSelectionMessage: String
    
    private var filteredItems: [Item] {
        items
            .filter(filter)
            .filter(searchFilter)
    }
    
    private var groupedItems: [(category: Category, items: [Item])] {
        Dictionary(grouping: filteredItems, by: { $0.category })
                .map { (category: $0.key, items: $0.value) }
                .sorted {
                    $0.category.name.localizedCaseInsensitiveCompare($1.category.name) == .orderedAscending
                }
    }
    
    init(
        title: String,
        filter: @escaping (Item) -> Bool = { _ in true },
        onDone: @escaping ([Item]) -> Void,
        noSelectionMessage: String = "Нет доступных вещей"
    ) {
        self.title = title
        self.filter = filter
        self.onDone = onDone
        self.noSelectionMessage = noSelectionMessage
    }
    
    var body: some View {
        List {
            ForEach(groupedItems, id: \.category.id) { group in
                Section {
                    ForEach(group.items) { item in
                        row(item)
                    }
                } header: {
                    Text(group.category.name)
                }
            }
        }
        .navigationTitle(title)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Отмена") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button("Выбрать (\(selectedItems.count))") {
                    onDone(Array(selectedItems))
                    dismiss()
                }
                    .disabled(selectedItems.isEmpty)
            }
        }
        .searchable(text: $searchText)
        .overlay {
            if filteredItems.isEmpty {
                ContentUnavailableView("Ничего не найдено", systemImage: "suitcase.rolling", description: Text(noSelectionMessage))
            }
        }
    }
    
    private func row(_ item: Item) -> some View {
        let isSelected = selectedItems.contains(item)
        
        return Button {
            toggle(item)
        } label: {
            HStack {
                Text(item.name)
                
                Spacer()
                
                Text(Weight(item.weight).formatted)
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.blue)
                }
            }
        }
    }
    
    private func toggle(_ item: Item) {
        if (selectedItems.contains(item)) {
            selectedItems.remove(item)
        } else {
            selectedItems.insert(item)
        }
    }
    
    private func searchFilter(_ item: Item) -> Bool {
        searchText.isEmpty || item.name.localizedCaseInsensitiveContains(searchText)
    }
}

#Preview("Нет данных") {
    NavigationStack {
        ItemPicker(
            title: "Выбор вещи",
            onDone: { _ in }
        )
    }
}

#Preview("Есть данные") {
    return NavigationStack {
        ItemPicker(
            title: "Выбор вещи",
            filter: {_ in true},
            onDone: {_ in}
        )
    }
    .modelContainer(PreviewProvider.make(FullDataPreview.self))
}
