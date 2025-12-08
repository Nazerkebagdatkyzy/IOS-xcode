//
//  AdminAddClassView.swift
//  AttendanceTracker
//
//  Created by Nazerke Bagdatkyzy on 05.12.2025.
//

import SwiftUI
import CoreData

struct AdminAddClassView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Teacher.name, ascending: true)]
    ) private var teachers: FetchedResults<Teacher>

    @State private var name = ""
    @State private var selectedTeacher: Teacher?
    @State private var saved = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Сынып аты")) {
                    TextField("Мысалы: 3A", text: $name)
                }

                Section(header: Text("Мұғалім тағайындау")) {
                    Picker("Мұғалім", selection: $selectedTeacher) {
                        ForEach(teachers) { t in
                            Text(t.name ?? "").tag(Optional(t))
                        }
                    }
                }

                Button("Сақтау") {
                    let cls = ClassRoom(context: viewContext)
                    cls.id = UUID()
                    cls.name = name
                    cls.teacher = selectedTeacher
                    try? viewContext.save()
                    saved = true
                }
            }
            .navigationTitle("Сынып қосу")
            .alert(isPresented: $saved) {
                Alert(title: Text("Сақталды"), message: Text("Жаңа сынып қосылды"), dismissButton: .default(Text("OK")))
            }
        }
    }
}
