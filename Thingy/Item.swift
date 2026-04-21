import Foundation
import SwiftData

@Model
final class Item {
    var name: String
    var weight: Int
    
    init(name: String, weight: Int) {
        self.name = name
        self.weight = weight
    }
}
