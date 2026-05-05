import SwiftUI
import SwiftData

struct TripView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.appStateProvider) private var appStateProvider
    
    @Query private var trips: [Trip]
    
    @State private var isShowAddTrip: Bool = false
    
    @State private var editingTrip: Trip?
    
    @State private var isShowDeleteTripConfirmation: Bool = false
    @State private var deletingTrip: Trip? = nil
    
    private var activeTrip: Trip? {
        appStateProvider?.get().activeTrip
    }
    
    private var otherTrips: [Trip] {
        trips.filter{$0 != activeTrip}
    }
    
    var body: some View {
        List {
            if let activeTrip {
                Section {
                    tripRow(activeTrip)
                } header: {
                    Text("Активная поездка")
                }

            }
            
            Section {
                ForEach(otherTrips) { trip in
                    tripRow(trip)
                }
            } header: {
                Text("Архив поездок")
            }
        }
        .navigationTitle("Мои поездки")
        .toolbar {
            ToolbarItem {
                Button {
                    isShowAddTrip = true
                } label: {
                    Label("Добавить поездку", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $isShowAddTrip) {
            NavigationStack {
                TripEditorView()
            }
        }
        .sheet(item: $editingTrip) { trip in
            NavigationStack {
                TripEditorView(trip: trip)
            }
        }
        .alert("Удалить предмет?", isPresented: $isShowDeleteTripConfirmation, presenting: deletingTrip) { trip in
                Button("Удалить", role: .destructive) {
                    modelContext.delete(trip)
                }
                Button("Отмена", role: .cancel) {
                    deletingTrip = nil
                }
            } message: { trip in
                Text("Вы уверены, что хотите удалить поездку '\(trip.name)'? Все вложенные сумки и предметы поездки будут так же удалены. Это действие нельзя отменить.")
            }
        .overlay {
            if trips.isEmpty {
                ContentUnavailableView("Список поездок пуст", systemImage: "suitcase", description: Text("Добавьте поездку чтобы начать"))
            }
        }
    }
    
    func tripRow(_ trip: Trip) -> some View {
        NavigationLink {
            TripDetailView(trip)
        } label: {
            HStack {
                Text(trip.name)
                
                Spacer()
            }
            .foregroundStyle(trip == activeTrip ? .blue : .primary)
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                isShowDeleteTripConfirmation = true
                deletingTrip = trip
            } label: {
                Label("Удалить", systemImage: "trash")
            }
        }
        .contextMenu {
            Button("Редактировать") {
                editingTrip = trip
            }
            
            Button("Дублировать") {
                let newTrip = trip.duplicate(name: "\(trip.name) (копия)")
                modelContext.insert(newTrip)
            }
            
            if trip != activeTrip {
                Button("Сделать активной") {
                    withAnimation{
                        appStateProvider?.get().activeTrip = trip
                    }
                }
            } else {
                Button("В архив") {
                    withAnimation{
                        appStateProvider?.get().activeTrip = nil
                    }
                }
            }
        }
    }
}

#Preview("Пусто") {
    NavigationStack {
        TripView()
    }
}

#Preview("Добавлены поездки") {
    let container = PreviewProvider.make(FullDataPreview.self)
    
    return NavigationStack {
        TripView()
    }
    .modelContainer(container)
    .environment(\.appStateProvider, AppStateProvider(context: container.mainContext))
}
