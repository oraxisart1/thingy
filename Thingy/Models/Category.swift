import Foundation
import SwiftData

@Model
class Category {
    var name: String
    
    @Relationship(deleteRule: .cascade, inverse: \Item.category)
    var items = [Item]()
    
    init(name: String) {
        self.name = name
    }
}
