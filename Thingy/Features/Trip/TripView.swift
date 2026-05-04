import SwiftUI
import SwiftData

struct TripView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query private var trips: [Trip]
    
    @State private var isShowAddTrip: Bool = false
    
    @State private var editingTrip: Trip?
    
    @State private var isShowDeleteTripConfirmation: Bool = false
    @State private var deletingTrip: Trip? = nil
    
    var body: some View {
        List {
            ForEach(trips) { trip in
                NavigationLink {
                    TripDetailView(trip)
                } label: {
                    HStack {
                        Text(trip.name)
                        
                        Spacer()
                    }
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
                }
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
}

#Preview("Пусто") {
    NavigationStack {
        TripView()
    }
}

#Preview("Добавлены поездки") {
    return NavigationStack {
        TripView()
    }
    .modelContainer(PreviewProvider.make(FullDataPreview.self))
}
