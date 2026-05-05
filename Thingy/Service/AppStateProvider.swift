import Foundation
import SwiftData

final class AppStateProvider {
    let context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    func get() -> AppState {
        if let existing = try? context.fetch(FetchDescriptor<AppState>()).first {
            return existing
        }
        
        let new = AppState()
        context.insert(new)
        try? context.save()
        return new
    }
}
