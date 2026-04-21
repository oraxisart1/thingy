import Foundation
import SwiftData

@Model
final class ItemModel {
    var name: String
    var weight: Int
    
    var category: CategoryModel
    
    init(name: String, weight: Int, category: CategoryModel) {
        self.name = name
        self.weight = weight
        self.category = category
    }
}
