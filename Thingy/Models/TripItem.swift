import Foundation
import SwiftData

@Model
class TripItem {
    var name: String
    var weight: Int
    
    var baseItem: Item
    
    var parent: TripItem?
    
    @Relationship(deleteRule: .cascade, inverse: \TripItem.parent)
    var children: [TripItem] = []
    
    var isContainer: Bool {
        !children.isEmpty
    }
    
    var totalWeight: Int {
        children.reduce(weight) { $0 + $1.totalWeight }
    }
    
    init(name: String, weight: Int, baseItem: Item, parent: TripItem? = nil) {
        self.name = name
        self.weight = weight
        self.baseItem = baseItem
        self.parent = parent
    }
}
