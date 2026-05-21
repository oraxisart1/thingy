import SwiftUI
import SwiftData

struct TripContainerDetailView: View {
    @Environment(\.modelContext) private var modelContext
    
    var tripItem: TripItem
    
    @State private var isShowAddItems = false
    
    var navigationTitle: String {
        tripItem.baseItem.name
    }
    
    var sortedChildren: [TripItem] {
        tripItem.children.sorted{!$0.isChecked && $1.isChecked}
    }
    
    init(_ item: TripItem) {
        self.tripItem = item
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if let maxWeight = tripItem.maxWeight {
                VStack(alignment: .center) {
                    Text("\(Weight(tripItem.totalWeight).formatted) / \(Weight(maxWeight).formatted)")
                        .font(.subheadline)
                        .foregroundColor(tripItem.isOverweight ? .red : .secondary)
                    
                    ProgressView(value: tripItem.weightPercentage ?? 0)
                        .tint(tripItem.isOverweight ? .red : .blue)
                }
            }

            List() {
                ForEach(sortedChildren) {children in
                if !children.isContainer {
                    HStack(spacing: 12) {
                        Button {
                            withAnimation{
                                children.isChecked.toggle()
                            }
                        } label: {
                            Image(systemName: children.isChecked ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(children.isChecked ? Color.accentColor : Color.secondary)
                                .imageScale(.large)
                        }
                        .buttonStyle(.plain)

                        Text(children.baseItem.name)

                        Spacer()

                        Text("\(Weight(children.totalWeight).formatted)")
                            .font(.subheadline)
                            .foregroundStyle(children.totalWeight > 0 ? Color.secondary : Color.red)
                    }
                } else {
                    HStack(spacing: 12) {
                        Button {
                            withAnimation{
                                children.isChecked.toggle()
                            }
                        } label: {
                            Image(systemName: children.isChecked ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(children.isChecked ? Color.accentColor : Color.secondary)
                                .imageScale(.large)
                        }
                        .buttonStyle(.plain)

                        NavigationLink {
                            TripContainerDetailView(children)
                        } label: {
                            HStack {
                                Text(children.baseItem.name)

                                Spacer()

                                Text("\(Weight(children.totalWeight).formatted)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .onDelete(perform: delete)
            }
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem {
                Button {
                    isShowAddItems = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $isShowAddItems) {
            NavigationStack {
                AddItemToContainerView(tripItem)
            }
        }
        .overlay {
            if tripItem.children.isEmpty {
                ContentUnavailableView("Сумка пуста", systemImage: "suitcase.rolling", description: Text("Добавьте вещи для подсчета веса"))
            }
        }
    }
    
    private func delete(_ indexes: IndexSet) {
        for index in indexes {
            modelContext.delete(sortedChildren[index])
        }
    }
}

#Preview("Пустая сумка") {
    let container = PreviewProvider.make(FullDataPreview.self)
    let trip = try! container.mainContext.fetch(FetchDescriptor<Trip>()).first!
    
    return NavigationStack {
        TripContainerDetailView(trip.containers.first!)
    }
    .modelContainer(container)
}
