import Foundation
import SwiftData

enum SchemaV3: VersionedSchema {
    static var versionIdentifier = Schema.Version(3, 0, 0)
    
    static var models: [any PersistentModel.Type] {
        [
            Category.self,
            Item.self,
            TripItem.self,
            Trip.self,
            AppState.self,
        ]
    }
}
