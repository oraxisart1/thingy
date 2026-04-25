import Foundation

struct Weight {
    var weight: Int
    
    init(_ weight: Int) {
        self.weight = weight
    }
    
    var formatted: String {
        if (weight < 1000) {
            return "\(weight) г"
        }
        
        return "\(Double(weight) / 1000, default: "%.2f") кг"
    }
}
