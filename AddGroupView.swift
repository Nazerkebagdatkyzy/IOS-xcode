//
//  AddGroupView.swift
//  AttendanceTracke
//
//  Created by Nazerke Bagdatkyzy on 28.11.2025.
//

import SwiftUI
import CoreData   // ← МІНЕ ОСЫ ЖЕТІСПЕЙТІН ЕДІ


struct AddGroupView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var groupName = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Топ атауы")) {
                    TextField("Мысалы: 3A, 2Б", text: $groupName)
                }
            }
            .navigationTitle("Жаңа топ")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сақтау") {
                        addGroup()
                        dismiss()
                    }.disabled(groupName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Болдырмау") { dismiss() }
                }
            }
        }
    }

    private func addGroup() {
        let newGroup = Group(context: viewContext)
        newGroup.id = UUID()
        newGroup.name = groupName
        save()
    }

    private func save() {
        do {
            try viewContext.save()
        } catch {
            print("Error saving group: \(error)")
        }
    }

}
#Preview {
    AddGroupView()
}
