import Foundation
import SwiftData

enum FullDataPreview: PreviewProtocol {
    static func makeContainer() -> ModelContainer {
        let container = try! ModelContainer(
            for: Category.self, Item.self, TripItem.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        
        let context = container.mainContext
        
        let containers = Category(name: "Сумки")
        let clothes = Category(name: "Одежда")
        let other = Category(name: "Другое")
        
        context.insert(containers)
        context.insert(clothes)
        context.insert(other)
        
        for i in 1..<10 {
            let item = Item(name: "Сумка \(i)", weight: (i + 1) * 100, category: containers, kind: .container)
            containers.items.append(item)
        }
        
        for i in 1..<10 {
            let item = Item(name: "Одежда \(i)", weight: (i + 1) * 10, category: clothes)
            clothes.items.append(item)
        }
        
        for i in 1..<10 {
            let item = Item(name: "Другое \(i)", weight: (i + 1) * 20, category: other)
            other.items.append(item)
        }
        
        let firstContainer = TripItem(baseItem: containers.items[0])
        context.insert(firstContainer)
        let secondContainer = TripItem(baseItem: containers.items[1])
        context.insert(secondContainer)
        
        for item in clothes.items {
            firstContainer.children.append(TripItem(baseItem: item, parent: firstContainer))
        }
        
        let nestedContainer = TripItem(baseItem: containers.items[2], parent: secondContainer)
        for item in other.items {
            nestedContainer.children.append(TripItem(baseItem: item, parent: nestedContainer))
        }
        
        return container
    }
}
