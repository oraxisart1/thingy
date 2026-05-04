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
