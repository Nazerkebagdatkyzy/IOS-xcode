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

    // Сыныптағы студенттер (сортталған)
    private var students: [Student] {
        (classRoom.students as? Set<Student>)?
            .sorted { $0.studentNumber < $1.studentNumber } ?? []
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
                            VStack(alignment: .leading, spacing: 4) {
                                Text(st.name ?? "Аты жоқ")
                                    .font(.headline)
                                Text("№\(st.studentNumber)")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    // 👉 Студентті солға сырғытып өшіру
                    .onDelete(perform: deleteStudent)
                }
            }
        }

        .navigationTitle(classRoom.name ?? "Сынып")
        .sheet(isPresented: $showAddStudent) {
            AdminAddStudentView(classRoom: classRoom)
        }
    }

    // 🔥 Студентті Core Data-дан өшіру функциясы
    private func deleteStudent(at offsets: IndexSet) {
        let list = students
        for index in offsets {
            let student = list[index]
            viewContext.delete(student)
        }

        do {
            try viewContext.save()
            print("Студент өшірілді")
        } catch {
            print("Өшіру қатесі:", error.localizedDescription)
        }
    }
}
