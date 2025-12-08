//
//  AdminClassDetailView.swift
//  AttendanceTracker
//
//  Created by Nazerke Bagdatkyzy on 05.12.2025.
//
import SwiftUI
import CoreData

struct AdminClassDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var classRoom: ClassRoom

    @State private var showAddStudent = false
    @State private var showingAddStudent = false

    

    // Сыныптағы студенттер
    private var students: [Student] {
        (classRoom.students as? Set<Student>)?
            .sorted { ($0.studentNumber) < ($1.studentNumber) } ?? []
    }

    var body: some View {
        List {

            // -------- Сынып туралы ақпарат --------
            Section(header: Text("Сынып туралы")) {
                Text("Атауы: \(classRoom.name ?? "Анықталмаған")")
                Text("Студенттер саны: \(students.count)")
            }

            // -------- Студенттер --------
            Section(
                header:
                    HStack {
                        Text("Студенттер")
                        Spacer()
                        Button(action: { showAddStudent = true }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                                .font(.title3)
                        }
                    }
            ) {
                if students.isEmpty {
                    Text("Студенттер жоқ")
                        .foregroundColor(.gray)
                } else {
                    ForEach(students) { st in
                        NavigationLink(destination: AdminStudentDetailView(student: st)) {
                            VStack(alignment: .leading) {
                                Text(classRoom.name ?? "Сынып")
                                Text(st.name ?? "Аты жоқ")
                                Text("№\(st.studentNumber)")

                            }
                        }
                    }
                }
            }
        }

        .navigationTitle(classRoom.name ?? "Сынып")
        .sheet(isPresented: $showAddStudent) {
            AdminAddStudentView(classRoom: classRoom)
        }
    }
}
