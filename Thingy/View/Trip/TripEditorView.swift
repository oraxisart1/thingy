import SwiftUI
import SwiftData

struct TripEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let trip: Trip?
    
    @State private var name: String = ""
    
    @FocusState private var isNameFocused: Bool
    
    init(trip: Trip? = nil) {
        self.trip = trip
    }
    
    private var isNameValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    private var isFormValid: Bool {
        isNameValid
    }
    
    private var title: String {
        trip == nil ? "Добавить поездку" : "Редактировать поездку"
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
            if let trip {
                name = trip.name
            }
        }
    }
    
    private func save() {
        if let trip {
            trip.name = name
        } else {
            let newTrip = Trip(name: name)
            modelContext.insert(newTrip)
        }
    }
}

#Preview("Создание") {
    NavigationStack {
        TripEditorView()
    }
}

#Preview("Редактирование") {
    let container = PreviewProvider.make(FullDataPreview.self);
    let trip: Trip = try! container.mainContext.fetch(FetchDescriptor<Trip>()).first!
    
    return NavigationStack {
        TripEditorView(trip: trip)
    }
    .modelContainer(container)
}
