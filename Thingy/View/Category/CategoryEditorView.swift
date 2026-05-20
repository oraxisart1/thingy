import SwiftUI
import SwiftData

struct CategoryEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let category: Category?
    
    @State private var name: String = ""
    
    @FocusState private var isNameFocused: Bool
    
    init(category: Category? = nil) {
        self.category = category
    }
    
    private var isNameValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    private var isFormValid: Bool {
        isNameValid
    }
    
    private var title: String {
        category == nil ? "Добавить категорию" : "Редактировать категорию"
    }
    
    var body: some View {
        Form {
            VStack(alignment: .leading) {
                TextField("Название", text: $name)
                    .focused($isNameFocused)
                
                if !isNameValid && !name.isEmpty {
                    Text("Название не может быть пустым")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
        .navigationTitle(title)
        .toolbar{
            ToolbarItem(placement: .cancellationAction) {
                Button("Отмена") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Сохранить") {
                    withAnimation {
                        save()
                        dismiss()
                    }
                }
                .disabled(!isFormValid)
            }
        }
        .onAppear {
            if let category {
                name = category.name
            }
        }
    }
    
    private func save() {
        if let category {
            category.name = name
        } else {
            let newCategory = Category(name: name)
            modelContext.insert(newCategory)
        }
    }
}

#Preview {
    NavigationStack {
        CategoryEditorView()
    }
}
