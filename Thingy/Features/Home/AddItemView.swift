import SwiftUI
import SwiftData

struct AddItemView: View {
    enum WeightUnit: CaseIterable {
        case g
        case kg
        
        var title: String {
            switch self {
                case .g: return "г"
                case .kg: return "кг"
            }
        }
    }
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query private var categories: [CategoryModel]

    @State private var name = ""
    @State private var weightString = ""
    @State private var weightUnit: WeightUnit = .g
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
            
            HStack {
                VStack(alignment: .leading) {
                    TextField("Вес", text: $weightString)
                        .keyboardType(.numberPad)
                        .foregroundColor(isWeightValid ? .primary : .red)

                    if !isWeightValid {
                        Text("Введите корректное число больше 0")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
                Spacer()
                
                Picker("", selection: $weightUnit) {
                    ForEach(WeightUnit.allCases, id: \.self) { unit in
                        Text(unit.title)
                            .tag(unit)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 120)
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
            weight: weightUnit == .g ? weight : weight * 1000,
            category: category
        )
        
        category.items.append(newItem)
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
