import Foundation
import SwiftUI

struct AppStateProviderKey: EnvironmentKey {
    static let defaultValue: AppStateProvider? = nil
}

extension EnvironmentValues {
    var appStateProvider: AppStateProvider? {
        get { self[AppStateProviderKey.self] }
        set { self[AppStateProviderKey.self] = newValue }
    }
}
