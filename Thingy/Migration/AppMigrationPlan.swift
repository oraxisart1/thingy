import Foundation
import SwiftData

enum AppMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [
            SchemaV1.self,
            SchemaV2.self
        ]
    }
    
    static var stages: [MigrationStage] {
        []
    }
    
    static let migrateV1toV2 = MigrationStage.custom(
        fromVersion: SchemaV1.self,
        toVersion: SchemaV2.self,
        willMigrate: {_ in},
        didMigrate: { context in
            migrateTripItems(context: context)
        }
    )
    
    private static func migrateTripItems(context: ModelContext) {
        let defaultTrip = Trip(name: "Поездка")
        
        let tripItems = try! context.fetch(FetchDescriptor<TripItem>())
        
        for item in tripItems {
            item.trip = defaultTrip
        }
        
        try! context.save()
    }
}
