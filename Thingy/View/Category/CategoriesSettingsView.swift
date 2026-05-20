import SwiftUI
import SwiftData

struct CategoriesSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State private var isShowAddCategory: Bool = false
    @State private var isShowingDeleteAlert: Bool = false
    @State private var categoryPendingDeletion: Category? = nil
    @State private var editingCategory: Category? = nil
    
    @Query private var categories: [Category]
    
    var body: some View {
        List {
            ForEach(categories) {category in
                HStack {
                    Text(category.name)
                    Spacer()
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        categoryPendingDeletion = category
                        isShowingDeleteAlert = true
                    } label: {
                        Label("Удалить", systemImage: "trash")
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    editingCategory = category
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
                CategoryEditorView()
            }
        }
        .sheet(item: $editingCategory) { category in
            NavigationStack {
                CategoryEditorView(category: category)
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
    .modelContainer(for: Category.self, inMemory: true)
}
