import SwiftUI
import SwiftData

struct AddItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query private var categories: [CategoryModel]

    @State private var name = ""
    @State private var weightString = ""
    @State private var selectedCategory: CategoryModel?

    @FocusState private var isNameFocused: Bool

    private var isNameValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var isWeightValid: Bool {
        if weightString.isEmpty { return true }
        return Int(weightString) != nil && (Int(weightString) ?? 0) > 0
    }
    
    private var isCategoryValid: Bool {
        selectedCategory != nil
    }

    private var canSave: Bool {
        isNameValid && !weightString.isEmpty && isWeightValid && isCategoryValid
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

            VStack(alignment: .leading) {
                TextField("Вес (в граммах)", text: $weightString)
                    .keyboardType(.numberPad)
                    .foregroundColor(isWeightValid ? .primary : .red)

                if !isWeightValid {
                    Text("Введите корректное число больше 0")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            
            VStack(alignment: .leading) {
                Picker("Категория", selection: $selectedCategory) {
                    ForEach(categories) {category in
                        Text(category.name)
                            .tag(category as CategoryModel?)
                    }
                }
                
                if !isCategoryValid {
                    Text("Выберите категорию")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
        .navigationTitle("Новый предмет")
        .onAppear {
            isNameFocused = true
            selectedCategory = categories.first
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Добавить") {
                    save()
                }
                .disabled(!canSave)
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Отмена") { dismiss() }
            }
        }
    }
    
    private func save() {
        guard let category = selectedCategory,
              let weight = Int(weightString)
        else {
            return
        }
        
        let newItem = ItemModel(
            name: name,
            weight: weight,
            category: category
        )
        
        modelContext.insert(newItem)
        dismiss()
    }
}

#Preview {
    NavigationStack{
        AddItemView()
    }
    .modelContainer(for: ItemModel.self, inMemory: true)
    .modelContainer(for: CategoryModel.self, inMemory: true)
}
