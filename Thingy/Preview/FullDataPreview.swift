import Foundation
import SwiftData

enum FullDataPreview: PreviewProtocol {
    static func makeContainer() -> ModelContainer {
        let container = try! ModelContainer(
            for: Category.self, Item.self, TripItem.self, Trip.self,
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
            let item = Item(name: "Сумка \(i)", weight: (i + 1) * 100, kind: .container)
            containers.items.append(item)
        }
        
        for i in 1..<10 {
            let item = Item(name: "Одежда \(i)", weight: (i + 1) * 10)
            clothes.items.append(item)
        }
        
        for i in 1..<10 {
            let item = Item(name: "Другое \(i)", weight: (i + 1) * 20)
            other.items.append(item)
        }
        
        for i in 1..<3 {
            let trip = Trip(name: "Поездка \(i)")
            context.insert(trip)
            
            let firstContainer = TripItem(baseItem: containers.items[0], trip: trip)
            trip.items.append(firstContainer)
            let secondContainer = TripItem(baseItem: containers.items[1], trip: trip)
            trip.items.append(secondContainer)

            for item in clothes.items {
                firstContainer.children.append(TripItem(baseItem: item, trip: trip))
            }
            
            let nestedContainer = TripItem(baseItem: containers.items[2], trip: trip)
            for item in other.items {
                nestedContainer.children.append(TripItem(baseItem: item, trip: trip))
            }
        }
        
        return container
    }
}
