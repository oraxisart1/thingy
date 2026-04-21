import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [
        SortDescriptor(\Item.name)
    ]) private var items: [Item]
    @State private var isShowingAddSheet = false
    
    @State private var isShowingDeleteAlert = false
    @State private var itemPendingDeletion: Item?

    var body: some View {
        NavigationStack {
            List {
                ForEach(items) { item in
                    HStack {
                        Text(item.name)
                            .font(.headline)
                        
                        Spacer()
                        
                        Text(item.weight < 1000 ? "\(item.weight) г" : "\(Double(item.weight) / 1000, specifier: "%.2f") кг")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            itemPendingDeletion = item
                            isShowingDeleteAlert = true
                        } label: {
                            Label("Удалить", systemImage: "trash")
                        }
                    }
                }
            }
            .navigationTitle("Мои вещи")
            .toolbar {
                // Кнопка "+" в верхнем правом углу
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .alert("Удалить предмет?", isPresented: $isShowingDeleteAlert, presenting: itemPendingDeletion) { item in
                    Button("Удалить", role: .destructive) {
                        delete(item)
                    }
                    Button("Отмена", role: .cancel) {
                        itemPendingDeletion = nil
                    }
                } message: { item in
                    Text("Вы уверены, что хотите удалить '\(item.name)'? Это действие нельзя отменить.")
                }
            // Вызываем экран добавления
            .sheet(isPresented: $isShowingAddSheet) {
                AddItemView() // Мы создадим эту View ниже
            }
            .overlay {
                if items.isEmpty {
                    ContentUnavailableView("Список пуст", systemImage: "archivebox", description: Text("Добавьте что-нибудь, чтобы увидеть это здесь"))
                }
            }
        }
    }
    
    private func delete(_ item: Item) {
        modelContext.delete(item)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
