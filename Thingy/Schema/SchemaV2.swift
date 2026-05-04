import Foundation
import SwiftData

enum SchemaV2: VersionedSchema {
    static var versionIdentifier = Schema.Version(2, 0, 0)
    
    static var models: [any PersistentModel.Type] {
        [
            Category.self,
            Item.self,
            TripItem.self,
            Trip.self,
        ]
    }
}
