import SwiftUI
import SwiftData

struct AddItemToContainerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    var tripItem: TripItem
    
    @Query private var tripItems: [TripItem]
    
    private var usedItemsSet: Set<Item> {
        Set(tripItems.filter{$0.trip === tripItem.trip}.map(\.baseItem))
    }
    
    init(_ tripItem: TripItem) {
        self.tripItem = tripItem
    }
    
    var body: some View {
        ItemPicker(
            title: "Выбор вещей",
            filter: {item in !usedItemsSet.contains(item)},
            onDone: add
        )
    }
    
    private func add(_ items: [Item]) {
        items.forEach({item in
            tripItem.children.append(TripItem(baseItem: item, trip: tripItem.trip!))
        })
    }
}

#Preview {
    let container = PreviewProvider.make(FullDataPreview.self)
    
    let trip = try! container.mainContext.fetch(FetchDescriptor<Trip>()).first!
    
    return NavigationStack {
        AddItemToContainerView(trip.containers.first!)
    }
    .modelContainer(container)
}
