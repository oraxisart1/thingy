import SwiftUI
import SwiftData

struct TripContainerSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    var container: TripItem

    @State private var maxWeight: Int?
    @State private var isWeightValid: Bool = true

    init(container: TripItem) {
        self.container = container
    }

    private var canSave: Bool {
        isWeightValid
    }
    
    var body: some View {
        Form {
            WeightInput(weightInGrams: $maxWeight, isValid: $isWeightValid, allowEmpty: true, allowZero: true)
        }
        .navigationTitle("Настройка")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Отмена") {
                    withAnimation {
                        dismiss()
                    }
                }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button("Сохранить") {
                    withAnimation {
                        save()
                        dismiss()
                    }
                }
                .disabled(!canSave)
            }
        }
        .onAppear {
            maxWeight = container.maxWeight
        }
    }
    
    private func save() {
        container.maxWeight = (maxWeight ?? 0) > 0 ? maxWeight : nil
        try? modelContext.save()
    }
}

#Preview {
    NavigationStack{
        TripContainerSettingsView(container: TripItem(baseItem: Item(name: "Чемодан", weight: 5000, category: Category(name: "Сумки"), kind: .container), trip: Trip(name: "Поездка 1"), maxWeight: 6000))
    }
}
