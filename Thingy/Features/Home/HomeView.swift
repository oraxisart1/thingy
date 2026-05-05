import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [
        SortDescriptor(\Category.name)
    ]) private var categories: [Category]
    @State private var isShowingAddSheet = false
    
    @State private var isShowingDeleteAlert = false
    @State private var itemPendingDeletion: Item?
    @State private var editingItem: Item?

    @State private var categoryPendingSelection: Category?
    
    @State private var searchText = ""
    
    private var nonEmptyCategories: [Category] {
        categories.filter { !filterItems($0.items).isEmpty }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(nonEmptyCategories) { category in
                        Button {
                            categoryPendingSelection = category
                        } label: {
                            Text(category.name)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.gray.opacity(0.2))
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding()
            }
            
            ScrollViewReader { proxy in
                List {
                    ForEach(nonEmptyCategories) {category in
                        Section {
                            ForEach(filterItems(sortedItems(category.items))) { item in
                                HStack {
                                    Text(item.name)
                                        .font(.headline)
                                    
                                    Spacer()
                                    
                                    Text(Weight(item.weight).formatted)
                                        .font(.subheadline)
                                        .foregroundStyle(item.weight > 0 ? Color.secondary : Color.red)
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
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    editingItem = item
                                }
                            }
                        } header: {
                            Text(category.name)
                        }
                        .id(category.id)
                    }
                }
                .onChange(of: categoryPendingSelection) { _, category in
                    if let category {
                        withAnimation {
                            proxy.scrollTo(category.id, anchor: .top)
                        }
                    }
                }
                .searchable(text: $searchText)
            }
        }
        .navigationTitle("Мои вещи")
        .toolbar {
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
        .sheet(isPresented: $isShowingAddSheet) {
            NavigationStack {
                ItemEditorView()
            }
        }
        .sheet(item: $editingItem) { item in
            NavigationStack {
                ItemEditorView(item: item)
            }
        }
        .overlay {
            if nonEmptyCategories.isEmpty {
                ContentUnavailableView("Список пуст", systemImage: "archivebox", description: Text("Добавьте что-нибудь, чтобы увидеть это здесь"))
            }
        }
    }
    
    private func delete(_ item: Item) {
        modelContext.delete(item)
    }
    
    private func sortedItems(_ items: [Item]) -> [Item] {
        items.sorted {$0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending}
    }
    
    private func filterItems(_ items: [Item]) -> [Item] {
        if searchText.isEmpty {
            return items
        }
        
        return items.filter{$0.name.localizedCaseInsensitiveContains(searchText)}
    }
}

#Preview("С данными") {
    return NavigationStack {
        HomeView()
    }
    .modelContainer(PreviewProvider.make(FullDataPreview.self))
}

#Preview("Пусто") {
    NavigationStack {
        HomeView()
    }
    .modelContainer(for: Category.self, inMemory: true)
}
