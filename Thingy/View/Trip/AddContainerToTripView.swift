import SwiftUI
import SwiftData

struct AddContainerToTripView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Query private var tripItems: [TripItem]
    
    private var usedItemsSet: Set<Item> {
        Set(tripItems.filter{$0.trip === trip}.map(\.baseItem))
    }
    
    let trip: Trip
    
    init(_ trip: Trip) {
        self.trip = trip
    }
    
    var body: some View {
        ItemPicker(
            title: "Выбор сумки",
            filter: {item in !usedItemsSet.contains(item) && item.isContainer},
            onDone: add,
            noSelectionMessage: "Нет доступных сумок"
        )
    }
    
    private func add(_ items: [Item]) {
        items.forEach({
            trip.items.append(TripItem(baseItem: $0, trip: trip))
        })
        
        dismiss()
    }
}

#Preview("Нет доступных сумок") {
    NavigationStack {
        AddContainerToTripView(Trip(name: "Поездка"))
    }
    .modelContainer(for: Item.self, inMemory: true)
    .modelContainer(for: TripItem.self, inMemory: true)
}

#Preview("Есть доступные сумки") {
    let container = PreviewProvider.make(FullDataPreview.self)
    
    return NavigationStack {
        AddContainerToTripView(try! container.mainContext.fetch(FetchDescriptor<Trip>()).first!)
    }
        .modelContainer(container)
}
