import SwiftUI

struct WeightInput: View {
    enum WeightUnit: CaseIterable, Hashable {
        case g
        case kg
        
        var title: String {
            switch self {
                case .g: return "г"
                case .kg: return "кг"
            }
        }
    }
    
    @Binding var weightInGrams: Int?
    var isValid: Binding<Bool>? = nil
    var allowEmpty: Bool = false
    var allowZero: Bool = false

    @State private var weightString: String = ""
    @State private var selectedUnit: WeightUnit = .g
    @FocusState private var isFocused: Bool
    @State private var hasInteracted: Bool = false

    private var internalError: String? {
        if weightString.isEmpty {
            return allowEmpty ? nil : "Введите вес"
        }

        guard let value = Int(weightString) else {
            return "Введите корректное число"
        }

        // Проверяем отрицательное
        if value < 0 {
            return "Вес не может быть отрицательным"
        }

        // Проверяем ноль
        if value == 0 && !allowZero {
            return "Вес должен быть больше 0"
        }

        return nil
    }

    var shouldShowError: Bool {
        hasInteracted && internalError != nil
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                TextField("Вес", text: $weightString)
                    .keyboardType(.numberPad)
                    .focused($isFocused)
                    .onChange(of: weightString) {
                        updateWeight()
                        updateValidation()
                    }
                    .onChange(of: selectedUnit) {
                        updateWeight()
                        updateValidation()
                    }
                    .onChange(of: isFocused) {
                        if !hasInteracted {
                            hasInteracted = true
                        }
                    }
                if shouldShowError, let error = internalError {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }

            Spacer()

            Picker("", selection: $selectedUnit) {
                ForEach(WeightUnit.allCases, id: \.self) { unit in
                    Text(unit.title)
                        .tag(unit)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 120)
        }
        .onAppear {
            loadInitialValue()
            updateValidation()
        }
    }

    private func updateValidation() {
        isValid?.wrappedValue = internalError == nil
    }
    
    private func loadInitialValue() {
        guard let weight = weightInGrams, weight > 0 else {
            return
        }
        
        weightString = "\(weight)"
    }
    
    private func updateWeight() {
        guard let value = Int(weightString), value >= 0 else {
            weightInGrams = nil
            return
        }
        
        weightInGrams = selectedUnit == .g ? value : value * 1000
    }
}

#Preview("Без ошибки") {
    @Previewable @State var weight: Int? = 1000
    
    Form {
        WeightInput(weightInGrams: $weight)
    }
}
