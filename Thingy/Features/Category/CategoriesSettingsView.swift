import SwiftUI
import SwiftData

struct CategoriesSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State private var isShowAddCategory: Bool = false
    @State private var isShowingDeleteAlert: Bool = false
    @State private var categoryPendingDeletion: CategoryModel? = nil
    
    @Query private var categories: [CategoryModel]
    
    var body: some View {
        List {
            ForEach(categories) {category in
                Text(category.name)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            categoryPendingDeletion = category
                            isShowingDeleteAlert = true
                        } label: {
                            Label("Удалить", systemImage: "trash")
                        }
                    }
            }
        }
        .navigationTitle("Категории")
        .toolbar{
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isShowAddCategory = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $isShowAddCategory) {
            NavigationStack {
                AddCategoryView()
            }
        }
        .alert("Удалить предмет?", isPresented: $isShowingDeleteAlert, presenting: categoryPendingDeletion) { category in
                Button("Удалить", role: .destructive) {
                    modelContext.delete(category)
                }
                .disabled(!category.items.isEmpty)
                Button("Отмена", role: .cancel) {
                    categoryPendingDeletion = nil
                }
            } message: { category in
                Text("Вы уверены, что хотите удалить категорию '\(category.name)'? Это действие нельзя отменить.")
            }
    }
}

#Preview {
    NavigationStack {
        CategoriesSettingsView()
    }
    .modelContainer(for: CategoryModel.self, inMemory: true)
}
