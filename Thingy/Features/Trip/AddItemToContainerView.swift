import SwiftUI
import SwiftData

struct AddItemToContainerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    var tripItem: TripItem
    
    @Query private var existingTripItems: [TripItem]
    
    private var usedItems: Set<Item> {
        Set(existingTripItems.map{$0.baseItem})
    }
    
    init(_ tripItem: TripItem) {
        self.tripItem = tripItem
    }
    
    var body: some View {
        ItemPicker(
            title: "Выбор вещей",
            filter: {item in !usedItems.contains(item)},
            onDone: add
        )
    }
    
    private func add(_ items: [Item]) {
        items.forEach({item in
            let newTripItem = TripItem(baseItem: item, parent: tripItem)
            
            tripItem.children.append(newTripItem)
        })
    }
}

#Preview {
    let container = try! ModelContainer(
        for: Category.self, Item.self, TripItem.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    let context = container.mainContext
    
    let category = Category(name: "Сумки")
    context.insert(category)
    
    let greenSuitcase = Item(name: "Зеленый чемодан", weight: 5000, category: category)
    category.items.append(greenSuitcase)
    
    let tripItem = TripItem(baseItem: greenSuitcase)
    context.insert(tripItem)
    
    let other = Category(name: "Другое")
    context.insert(other)
    
    let pen = Item(name: "Ручка", weight: 50, category: category)
    other.items.append(pen)
    
    
    return NavigationStack {
        AddItemToContainerView(tripItem)
    }
    .modelContainer(container)
}
