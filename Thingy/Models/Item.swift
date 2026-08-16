import Foundation
import SwiftData

@Model
final class Item {
    var name: String
    var weight: Int
    var kind: ItemKind? = ItemKind.regular
    var isArchived: Bool = false
    
    var category: Category
    
    @Relationship(deleteRule: .cascade, inverse: \TripItem.baseItem)
    var tripItems = [TripItem]()
    
    var isContainer: Bool {
        kind == .container
    }
    
    init(name: String, weight: Int, category: Category, kind: ItemKind = .regular) {
        self.name = name
        self.weight = weight
        self.kind = kind
        self.category = category
    }
    
    enum ItemKind: String, Codable {
        case regular
        case container
    }
}

extension Item {
    func archive() -> Self {
        isArchived = true
        return self
    }
    
    func unarchive() -> Self {
        isArchived = false
        return self
    }
}
