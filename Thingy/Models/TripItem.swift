import Foundation
import SwiftData

@Model
class TripItem {
    @Relationship(deleteRule: .nullify)
    var baseItem: Item
    
    var parent: TripItem?
    
    var trip: Trip?
    
    @Relationship(deleteRule: .cascade, inverse: \TripItem.parent)
    var children = [TripItem]()
    
    var isContainer: Bool {
        baseItem.isContainer
    }
    
    var totalWeight: Int {
        children.reduce(baseItem.weight) { $0 + $1.totalWeight }
    }
    
    init(baseItem: Item, trip: Trip) {
        self.baseItem = baseItem
        self.trip = trip
    }
}

extension TripItem {
    func clone(for trip: Trip, parent: TripItem? = nil) -> TripItem {
        let newItem = TripItem(baseItem: baseItem, trip: trip)
        newItem.parent = parent
        
        for child in children {
            let newChild = child.clone(for: trip, parent: newItem)
            newItem.children.append(newChild)
            trip.items.append(newChild)
        }
        
        return newItem
    }
}
