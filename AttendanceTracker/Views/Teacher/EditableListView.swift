//
//  EditableListView.swift
//  AttendanceTracker
//
//  Created by Nazerke Bagdatkyzy on 09.12.2025.
//
import SwiftUI

struct EditableListView: View {
    var title: String
    @Binding var items: [String]
    @State private var newItem: String = ""

    var body: some View {
        VStack(spacing:12) {
            HStack {
                TextField("Жаңа элемент", text: $newItem)
                    .textFieldStyle(.roundedBorder)
                Button("Қосу") {
                    let t = newItem.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !t.isEmpty else { return }
                    items.append(t)
                    newItem = ""
                }
            }.padding()

            List {
                ForEach(items, id:\.self) { it in
                    Text(it)
                }
                .onDelete { offsets in items.remove(atOffsets: offsets) }
            }
        }
        .navigationTitle(title)
    }
}
