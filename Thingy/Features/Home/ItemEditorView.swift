import SwiftUI
import SwiftData

struct ItemEditorView: View {
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
    
    let item: Item?
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query(
        sort: [
            SortDescriptor(\Category.name)
        ]
    ) private var categories: [Category]

    @State private var name = ""
    @State private var weightString = ""
    @State private var weightUnit: WeightUnit = .g
    @State private var selectedCategory: Category? = nil
    @State private var isContainer: Bool = false

    @FocusState private var isNameFocused: Bool
    
    init(item: Item? = nil) {
        self.item = item
    }

    private var isNameValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var isWeightValid: Bool {
        if weightString.isEmpty { return true }
        return Int(weightString) != nil && (Int(weightString) ?? 0) >= 0
    }
    
    private var isCategoryValid: Bool {
        selectedCategory != nil
    }

    private var canSave: Bool {
        isNameValid && !weightString.isEmpty && isWeightValid && isCategoryValid
    }
    
    private var title: String {
        item == nil ? "Добавить вещь" : "Изменить вещь"
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
                        Text("Введите корректное число больше или равное 0")
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
                    if selectedCategory == nil {
                        Text("Выберите категорию")
                            .foregroundColor(.secondary)
                            .tag(nil as Category?)
                    }
                    
                    ForEach(categories) {category in
                        Text(category.name)
                            .tag(category as Category?)
                    }
                }
            }
            
            Section {
                Toggle(isOn: $isContainer) {
                    Label("Сумка", systemImage: "suitcase")
                }
            } footer: {
                Text("Позволяет добавлять предметы внутрь")
            }
        }
        .navigationTitle(title)
        .onAppear {
            isNameFocused = true
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Сохранить") {
                    withAnimation {
                        save()
                        dismiss()
                    }
                }
                .disabled(!canSave)
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Отмена") { dismiss() }
            }
        }
        .onAppear {
            if let item {
                name = item.name
                weightString = "\(item.weight)"
                weightUnit = .g
                selectedCategory = item.category
                if case .container = item.kind {
                    isContainer = true
                }
            }
        }
    }
    
    private func save() {
        guard let category = selectedCategory,
              let weight = Int(weightString)
        else {
            return
        }
        
        let weightInGrams: Int = weightUnit == .g ? weight : weight * 1000
        let kind = isContainer ? Item.ItemKind.container : .regular
        
        if let item {
            item.name = name
            item.weight = weightInGrams
            item.category = category
            item.kind = kind
        } else {
            let newItem = Item(
                name: name,
                weight: weightUnit == .g ? weight : weight * 1000,
                category: category,
                kind: isContainer ? .container : .regular
            )
            
            category.items.append(newItem)
        }
    }
}

#Preview {
    NavigationStack{
        ItemEditorView()
    }
    .modelContainer(PreviewProvider.make(FullDataPreview.self))
}
