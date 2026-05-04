import SwiftUI
import SwiftData

struct TripDetailView: View {
    @Environment(\.modelContext) private var modelContext
    
    var trip: Trip
    
    @State private var isShowAddContainer: Bool = false
    
    @State private var isShowDeleteContainerConfirmation: Bool = false
    @State private var deletingItem: TripItem? = nil
    
    init(_ trip: Trip) {
        self.trip = trip
    }
    
    var body: some View {
        List {
            ForEach(trip.containers) { container in
                NavigationLink {
                    TripContainerDetailView(container)
                } label: {
                    HStack {
                        Text(container.baseItem.name)
                        
                        Spacer()
                        
                        Text("\(Weight(container.totalWeight).formatted) (\(container.children.count))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        isShowDeleteContainerConfirmation = true
                        deletingItem = container
                    } label: {
                        Label("Удалить", systemImage: "trash")
                    }
                }
            }
        }
        .navigationTitle(trip.name)
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
                AddContainerToTripView(trip)
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
            if trip.containers.isEmpty {
                ContentUnavailableView("Багаж пуст", systemImage: "suitcase", description: Text("Добавьте сумку чтобы начать"))
            }
        }
    }
}

#Preview("Пусто") {
    NavigationStack {
        TripDetailView(Trip(name: "Поездка"))
    }
}

#Preview("Добавлены сумки") {
    let container = PreviewProvider.make(FullDataPreview.self);
    let trip = try! container.mainContext
        .fetch(FetchDescriptor<Trip>())
        .first!
    
    return NavigationStack {
        TripDetailView(trip)
    }
    .modelContainer(container)
}
