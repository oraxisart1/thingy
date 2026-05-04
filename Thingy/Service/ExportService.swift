import Foundation
import SwiftData

final class ExportService {
    private let context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    func exportAll() throws {
        let categories = try! context.fetch(FetchDescriptor<Category>())
        let items = try! context.fetch(FetchDescriptor<Item>())
        let tripItems = try! context.fetch(FetchDescriptor<TripItem>())
        
        let backup = BackupDTO(
            categories: categories.map{CategoryDTO(from: $0)},
            items: items.map{ItemDTO(from: $0)},
            tripItems: tripItems.map{TripItemDTO(from: $0)}
        )
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        let data = try! encoder.encode(backup)
        
        try saveToFile(data)
    }
    
    private func saveToFile(_ data: Data) throws {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        
        let fileName = "backup_\(formatter.string(from: Date())).json"
        
        let url = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)
        
        try data.write(to: url)
    }
}

struct BackupDTO: Codable {
    let categories: [CategoryDTO]
    let items: [ItemDTO]
    let tripItems: [TripItemDTO]
}

struct CategoryDTO: Codable {
    let name: String
    
    init(from model: Category) {
        self.name = model.name
    }
}

struct ItemDTO: Codable {
    let name: String
    let weight: Int
    let categoryName: String
    let kind: Item.ItemKind
    
    init(from model: Item) {
        self.name = model.name
        self.weight = model.weight
        self.categoryName = model.category.name
        self.kind = model.kind ?? .regular
    }
}

struct TripItemDTO: Codable {
    let itemName: String
    let parentItemName: String?
    
    init(from model: TripItem) {
        self.itemName = model.baseItem.name
        self.parentItemName = model.parent == nil ? nil : model.parent!.baseItem.name
    }
}
