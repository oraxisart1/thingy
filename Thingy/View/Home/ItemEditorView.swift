import SwiftUI
import SwiftData

struct ItemEditorView: View {
    let item: Item?
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query(
        sort: [
            SortDescriptor(\Category.name)
        ]
    ) private var categories: [Category]

    @State private var name = ""
    @State private var selectedCategoryId: PersistentIdentifier?
    @State private var weight: Int? = nil
    @State private var isContainer: Bool = false

    @FocusState private var isNameFocused: Bool
    
    init(item: Item? = nil) {
        self.item = item
    }

    private var isNameValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var isWeightValid: Bool {
        guard let weight, weight > 0 else {
            return false
        }
        
        return true
    }
    
    private var isCategoryValid: Bool {
        selectedCategoryId != nil
    }

    private var canSave: Bool {
        isNameValid && isWeightValid && isCategoryValid
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
            
            WeightInput(weightInGrams: $weight)
            
            VStack(alignment: .leading) {
                Picker("Категория", selection: $selectedCategoryId) {
                    Text("Выберите категорию")
                        .tag(nil as PersistentIdentifier?)

                    ForEach(categories) { category in
                        Text(category.name)
                            .tag(category.persistentModelID)
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
                selectedCategoryId = item.category.persistentModelID
                weight = item.weight
                if case .container = item.kind {
                    isContainer = true
                }
            }
        }
    }
    
    private func save() {
        guard let category = categories.first(where: {
                $0.persistentModelID == selectedCategoryId
            }),
            let weight
        else {
            return
        }
        
        let kind = isContainer ? Item.ItemKind.container : .regular
        
        if let item {
            item.name = name
            item.weight = weight
            item.category = category
            item.kind = kind
        } else {
            let newItem = Item(
                name: name,
                weight: weight,
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
