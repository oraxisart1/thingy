import Foundation
import SwiftData

@Model
class CategoryModel {
    var name: String
    
    @Relationship(deleteRule: .deny, inverse: \ItemModel.category)
    var items = [ItemModel]()
    
    init(name: String) {
        self.name = name
    }
}
