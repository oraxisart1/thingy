import SwiftUI
import SwiftData

struct TripContainerDetailView: View {
    @Environment(\.modelContext) private var modelContext
    
    var tripItem: TripItem
    
    @State private var isShowAddItems = false
    
    init(_ item: TripItem) {
        self.tripItem = item
    }
    
    var body: some View {
        List() {
            ForEach(tripItem.children) {children in
                HStack {
                    Text(children.baseItem.name)
                    
                    Spacer()
                    
                    Text("\(Weight(children.totalWeight).formatted)")
                        .font(.subheadline)
                        .foregroundStyle(children.totalWeight > 0 ? Color.secondary : Color.red)
                }
            }
            .onDelete(perform: delete)
        }
        .navigationTitle(Text(tripItem.baseItem.name))
        .toolbar {
            ToolbarItem {
                Button {
                    isShowAddItems = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $isShowAddItems) {
            NavigationStack {
                AddItemToContainerView(tripItem)
            }
        }
        .overlay {
            if tripItem.children.isEmpty {
                ContentUnavailableView("Сумка пуста", systemImage: "suitcase.rolling", description: Text("Добавьте вещи для подсчета веса"))
            }
        }
    }
    
    private func delete(_ indexes: IndexSet) {
        for index in indexes {
            modelContext.delete(tripItem.children[index])
        }
    }
}

#Preview("Пустая сумка") {
    let container = try! ModelContainer(
        for: Category.self, Item.self, TripItem.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    let context = container.mainContext
    
    let category = Category(name: "Сумки")
    context.insert(category)
    
    let greenSuitcase = Item(name: "Зеленый чемодан", weight: 5000, category: category)
    category.items.append(greenSuitcase)
    
    let tripItem = TripItem(baseItem: greenSuitcase)
    context.insert(tripItem)
    
    
    return NavigationStack {
        TripContainerDetailView(tripItem)
    }
    .modelContainer(container)
}
