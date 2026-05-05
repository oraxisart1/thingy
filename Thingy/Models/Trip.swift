import Foundation
import SwiftData

@Model
class Trip {
    var name: String
    
    @Relationship(deleteRule: .cascade, inverse: \TripItem.trip)
    var items = [TripItem]()
    
    var containers: [TripItem] {
        items.filter{$0.parent == nil && $0.isContainer}
    }
    
    init(name: String) {
        self.name = name
    }
}

extension Trip {
    var usedBaseItems: [Item] {
        items.map{$0.baseItem}
    }
    
    func duplicate(name: String) -> Trip {
        let newTrip = Trip(name: name)
        
        for item in items where item.parent == nil {
            newTrip.items.append(item.clone(for: newTrip))
        }
        
        return newTrip
    }
}
