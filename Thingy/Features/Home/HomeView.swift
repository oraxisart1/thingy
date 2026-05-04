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
    
    private var nonEmptyCategories: [Category] {
        categories.filter { !$0.items.isEmpty }
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
                            ForEach(sortedItems(category.items)) { item in
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
}

#Preview("С данными") {
    let container = try! ModelContainer(
        for: Item.self, Category.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    let context = container.mainContext
        
    let clothes = Category(name: "Одежда")
    let tech = Category(name: "Электроника")
    let cosmetics = Category(name: "Косметика")
    let other = Category(name: "Другое")
    
    let item1 = Item(name: "Футболка", weight: 200)
    let item2 = Item(name: "Штаны", weight: 500)
    let item3 = Item(name: "Ноутбук", weight: 1500)
    let item4 = Item(name: "Телефон", weight: 200)
    let item5 = Item(name: "Зубная щетка", weight: 100)
    let item6 = Item(name: "Ирригатор", weight: 500)
    let item7 = Item(name: "Шампунь", weight: 400)
    let item8 = Item(name: "Маска для волос", weight: 600)
    let item9 = Item(name: "Куртка", weight: 1500)
    let item10 = Item(name: "Кроссовки", weight: 1200)
    let item11 = Item(name: "Постельное белье", weight: 2000)
    let item12 = Item(name: "Одеяло", weight: 900)
    let item13 = Item(name: "Графин", weight: 500)
    
    
    context.insert(clothes)
    context.insert(tech)
    context.insert(cosmetics)
    context.insert(other)
    context.insert(item1)
    context.insert(item2)
    context.insert(item3)
    context.insert(item4)
    context.insert(item5)
    context.insert(item6)
    context.insert(item7)
    context.insert(item8)
    context.insert(item9)
    context.insert(item10)
    context.insert(item11)
    context.insert(item12)
    context.insert(item13)
    
    return NavigationStack {
        HomeView()
    }
    .modelContainer(container)
}

#Preview("Пусто") {
    NavigationStack {
        HomeView()
    }
    .modelContainer(for: Category.self, inMemory: true)
}
