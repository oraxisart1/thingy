import SwiftUI
import SwiftData

struct TripContainerDetailView: View {
    @Environment(\.modelContext) private var modelContext
    
    var tripItem: TripItem
    
    @State private var isShowAddItems = false
    
    var navigationTitle: String {
        tripItem.parent == nil ? "\(tripItem.baseItem.name) (\(Weight(tripItem.totalWeight).formatted))" : tripItem.baseItem.name
    }
    
    init(_ item: TripItem) {
        self.tripItem = item
    }
    
    var body: some View {
        List() {
            ForEach(tripItem.children) {children in
                if !children.isContainer {
                    HStack {
                        Text(children.baseItem.name)
                        
                        Spacer()
                        
                        Text("\(Weight(children.totalWeight).formatted)")
                            .font(.subheadline)
                            .foregroundStyle(children.totalWeight > 0 ? Color.secondary : Color.red)
                    }
                } else {
                    NavigationLink {
                        TripContainerDetailView(children)
                    } label: {
                        HStack {
                            Text(children.baseItem.name)
                            
                            Spacer()
                            
                            Text("\(Weight(children.totalWeight).formatted)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .onDelete(perform: delete)
        }
        .navigationTitle(navigationTitle)
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
    let container = PreviewProvider.make(FullDataPreview.self)
    let trip = try! container.mainContext.fetch(FetchDescriptor<Trip>()).first!
    
    return NavigationStack {
        TripContainerDetailView(trip.containers.first!)
    }
    .modelContainer(container)
}
