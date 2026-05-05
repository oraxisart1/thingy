import Foundation
import SwiftData

@Model
class AppState {
    @Attribute(.unique) var id: String

    var activeTrip: Trip?
    
    init(activeTrip: Trip? = nil) {
        self.id = "singleton"
        self.activeTrip = activeTrip
    }
}
