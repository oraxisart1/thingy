import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [
        SortDescriptor(\CategoryModel.name)
    ]) private var categories: [CategoryModel]
    @State private var isShowingAddSheet = false
    
    @State private var isShowingDeleteAlert = false
    @State private var itemPendingDeletion: ItemModel?
    

    @State private var categoryPendingSelection: CategoryModel?
    
    private var nonEmptyCategories: [CategoryModel] {
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
                            ForEach(category.items) { item in
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
                AddItemView()
            }
        }
        .overlay {
            if nonEmptyCategories.isEmpty {
                ContentUnavailableView("Список пуст", systemImage: "archivebox", description: Text("Добавьте что-нибудь, чтобы увидеть это здесь"))
            }
        }
    }
    
    private func delete(_ item: ItemModel) {
            modelContext.delete(item)
        }
}

#Preview("С данными") {
    let container = try! ModelContainer(
        for: ItemModel.self, CategoryModel.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    let context = container.mainContext
        
    let clothes = CategoryModel(name: "Одежда")
    let tech = CategoryModel(name: "Электроника")
    let cosmetics = CategoryModel(name: "Косметика")
    let other = CategoryModel(name: "Другое")
    
    let item1 = ItemModel(name: "Футболка", weight: 200, category: clothes)
    let item2 = ItemModel(name: "Штаны", weight: 500, category: clothes)
    let item3 = ItemModel(name: "Ноутбук", weight: 1500, category: tech)
    let item4 = ItemModel(name: "Телефон", weight: 200, category: tech)
    let item5 = ItemModel(name: "Зубная щетка", weight: 100, category: cosmetics)
    let item6 = ItemModel(name: "Ирригатор", weight: 500, category: cosmetics)
    let item7 = ItemModel(name: "Шампунь", weight: 400, category: cosmetics)
    let item8 = ItemModel(name: "Маска для волос", weight: 600, category: cosmetics)
    let item9 = ItemModel(name: "Куртка", weight: 1500, category: clothes)
    let item10 = ItemModel(name: "Кроссовки", weight: 1200, category: clothes)
    let item11 = ItemModel(name: "Постельное белье", weight: 2000, category: other)
    let item12 = ItemModel(name: "Одеяло", weight: 900, category: other)
    let item13 = ItemModel(name: "Графин", weight: 500, category: other)
    
    
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
    .modelContainer(for: CategoryModel.self, inMemory: true)
}
