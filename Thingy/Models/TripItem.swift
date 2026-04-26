import Foundation
import SwiftData

@Model
class TripItem {
    @Relationship(deleteRule: .nullify)
    var baseItem: Item
    
    var parent: TripItem?
    
    @Relationship(deleteRule: .cascade, inverse: \TripItem.parent)
    var children: [TripItem] = []
    
    var isContainer: Bool {
        baseItem.isContainer
    }
    
    var totalWeight: Int {
        children.reduce(baseItem.weight) { $0 + $1.totalWeight }
    }
    
    init(baseItem: Item, parent: TripItem? = nil) {
        self.baseItem = baseItem
        self.parent = parent
    }
}
