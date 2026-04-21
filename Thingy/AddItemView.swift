import SwiftUI
import SwiftData

struct AddItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var weightString = ""

    @FocusState private var isNameFocused: Bool

    private var isNameValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var isWeightValid: Bool {
        if weightString.isEmpty { return true }
        return Int(weightString) != nil && (Int(weightString) ?? 0) > 0
    }

    private var canSave: Bool {
        isNameValid && !weightString.isEmpty && isWeightValid
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Информация о предмете") {
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
                }
            }
            .navigationTitle("Новый предмет")
            .onAppear {
                isNameFocused = true
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Добавить") {
                        if let weight = Int(weightString) {
                            let newItem = Item(name: name, weight: weight)
                            modelContext.insert(newItem)
                            dismiss()
                        }
                    }
                    .disabled(!canSave)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    AddItemView()
        .modelContainer(for: Item.self, inMemory: true)
}
