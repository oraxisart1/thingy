import SwiftUI
import SwiftData

struct TripView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query private var tripItems: [TripItem]
    
    @State private var isShowAddContainer: Bool = false
    
    
    @State private var isShowDeleteContainerConfirmation: Bool = false
    @State private var deletingItem: TripItem? = nil
    
    private var rootItems: [TripItem] {
        tripItems.filter { $0.parent == nil }
    }
    
    var body: some View {
        List {
            ForEach(rootItems) { rootItem in
                NavigationLink {
                    TripContainerDetailView(rootItem)
                } label: {
                    HStack {
                        Text(rootItem.baseItem.name)
                        
                        Spacer()
                        
                        Text("\(Weight(rootItem.totalWeight).formatted) (\(rootItem.children.count))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        isShowDeleteContainerConfirmation = true
                        deletingItem = rootItem
                    } label: {
                        Label("Удалить", systemImage: "trash")
                    }
                }
            }
        }
        .navigationTitle("Сбор багажа")
        .toolbar {
            ToolbarItem {
                Button {
                    isShowAddContainer = true
                } label: {
                    Label("Добавить сумку", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $isShowAddContainer) {
            NavigationStack {
                AddContainerToTripView()
            }
        }
        .alert("Удалить предмет?", isPresented: $isShowDeleteContainerConfirmation, presenting: deletingItem) { item in
                Button("Удалить", role: .destructive) {
                    modelContext.delete(item)
                }
                Button("Отмена", role: .cancel) {
                    deletingItem = nil
                }
            } message: { item in
                Text("Вы уверены, что хотите удалить сумку для багажа '\(item.baseItem.name)'? Все вложенные предметы поездки будут так же удалены. Это действие нельзя отменить.")
            }
        .overlay {
            if rootItems.isEmpty {
                ContentUnavailableView("Багаж пуст", systemImage: "suitcase", description: Text("Добавьте сумку чтобы начать"))
            }
        }
    }
}

#Preview("Пусто") {
    NavigationStack {
        TripView()
    }
}

#Preview("Добавлены сумки") {
    return NavigationStack {
        TripView()
    }
    .modelContainer(PreviewProvider.make(FullDataPreview.self))
}
