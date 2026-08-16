import Foundation
import SwiftData

@Model
class TripItem {
    @Relationship(deleteRule: .nullify)
    var baseItem: Item
    var parent: TripItem?
    var trip: Trip
    var isChecked: Bool = false
    var maxWeight: Int? = nil
    
    @Relationship(deleteRule: .cascade, inverse: \TripItem.parent)
    var children = [TripItem]()
    
    var isContainer: Bool {
        baseItem.isContainer
    }
    
    var totalWeight: Int {
        children.reduce(baseItem.weight) { $0 + $1.totalWeight }
    }
    
    init(baseItem: Item, trip: Trip, parent: TripItem? = nil, maxWeight: Int? = nil) {
        self.baseItem = baseItem
        self.trip = trip
        self.parent = parent
        self.maxWeight = maxWeight
    }
}

extension TripItem {
    var weightPercentage: Double? {
        guard let maxWeight, maxWeight > 0 else { return nil }
        
        return Double(totalWeight) / Double(maxWeight)
    }
    
    var isOverweight: Bool {
        guard let maxWeight else { return false }
        
        return totalWeight > maxWeight
    }
    
    func duplicateForTrip(for trip: Trip, parent: TripItem? = nil) -> TripItem {
        let newItem = TripItem(baseItem: baseItem, trip: trip, parent: parent, maxWeight: maxWeight)

        for child in children where !child.baseItem.isArchived {
            let newChild = child.duplicateForTrip(for: trip, parent: newItem)
            newItem.children.append(newChild)
            trip.items.append(newChild)
        }

        return newItem
    }
}
