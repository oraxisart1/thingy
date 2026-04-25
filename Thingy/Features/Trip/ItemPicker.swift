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
            ForEach(filteredItems) { item in
                row(item)
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
    let container = try! ModelContainer(
        for: Category.self, Item.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    let context = container.mainContext
    
    let category = Category(name: "Другое")
    context.insert(category)
    
    category.items.append(Item(name: "Лопатка", weight: 100, category: category))
    category.items.append(Item(name: "Графин", weight: 200, category: category))
    
    return NavigationStack {
        ItemPicker(
            title: "Выбор вещи",
            filter: {item in
                item.weight > 100
            },
            onDone: {_ in}
        )
    }
    .modelContainer(container)
}
