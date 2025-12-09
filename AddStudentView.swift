//
//  AddStudentView.swift
//  AttendanceTracke
//
//  Created by Nazerke Bagdatkyzy on 28.11.2025.
//
import SwiftUI
import CoreData  

struct AddStudentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    var group: Group     // ← МІНЕ ОСЫ ЖЕТІСПЕЙТІН ЕДІ!!!

    @State private var studentName = ""

    var body: some View {
        Form {
            Section(header: Text("Студент аты-жөні")) {
                TextField("Аты-жөні", text: $studentName)
            }
        }
        .navigationTitle("Студент қосу")
        .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Сақтау") {
                            let s = Student(context: viewContext)
                            s.id = UUID()
                            s.name = studentName
                            s.group = group
                            try? viewContext.save()
                            dismiss()
                        }
                        .disabled(studentName.isEmpty)
                    }

            ToolbarItem(placement: .cancellationAction) {
                Button("Болдырмау") { dismiss() }
            }
        }
    }

    private func addStudent() {
        let newStudent = Student(context: viewContext)
        newStudent.id = UUID()
        newStudent.name = studentName
        newStudent.group = group

        do { try viewContext.save() }
        catch { print("Error saving student: \(error)") }

        dismiss()
    }

}

