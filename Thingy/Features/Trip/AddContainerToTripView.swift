import SwiftUI
import SwiftData

struct AddContainerToTripView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Query private var existingTripItems: [TripItem]
    
    private var usedItems: Set<Item> {
        Set(existingTripItems.map(\.baseItem))
    }
    
    var body: some View {
        ItemPicker(
            title: "Выбор сумки",
            filter: {item in !usedItems.contains(item) && item.isContainer},
            onDone: add,
            noSelectionMessage: "Нет доступных сумок"
        )
    }
    
    private func add(_ items: [Item]) {
        items.forEach({
            modelContext.insert(TripItem(baseItem: $0, parent: nil))
        })
        
        dismiss()
    }
}

#Preview("Нет доступных сумок") {
    NavigationStack {
        AddContainerToTripView()
    }
    .modelContainer(for: Item.self, inMemory: true)
    .modelContainer(for: TripItem.self, inMemory: true)
}

#Preview("Есть доступные сумки") {
    let container = try! ModelContainer(
        for: Item.self, TripItem.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    let context = container.mainContext
    
    let category = Category(name: "Other")
    context.insert(category)
    
    let greenSuitcase = Item(name: "Зеленый чемодан", weight: 5000, category: category, kind: .container)
    
    category.items.append(greenSuitcase)
    category.items.append(Item(name: "Розовый чемодан", weight: 5000, category: category, kind: .container))
    category.items.append(Item(name: "Рюкзак Тимошка", weight: 1500, category: category, kind: .container))
    category.items.append(Item(name: "Сумка Пума", weight: 500, category: category, kind: .container))
    
    context.insert(TripItem(baseItem: greenSuitcase))
    
    return NavigationStack {
        AddContainerToTripView()
    }
        .modelContainer(container)
}
