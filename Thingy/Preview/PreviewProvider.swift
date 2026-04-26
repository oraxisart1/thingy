import Foundation
import SwiftData

enum PreviewProvider {
    static func make(_ preview: PreviewProtocol.Type) -> ModelContainer {
        preview.makeContainer();
    }
}
