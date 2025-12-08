//
//  AdminStudentDetailView.swift
//  AttendanceTracker
//
//  Created by Nazerke Bagdatkyzy on 08.12.2025.
//
import SwiftUI
import CoreData


struct AdminStudentDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var student: Student

    var body: some View {
        Form {
            Section(header: Text("Студент")) {
                Text("Аты: \(student.name ?? "")")
                Text("Нөмірі: \(student.studentNumber)")
                Text("Сынып: \(student.classRoom?.name ?? "-")")
            }

            Button("Өшіру", role: .destructive) {
                deleteStudent()
            }
        }
        .navigationTitle("Студент")
    }

    private func deleteStudent() {
        viewContext.delete(student)
        try? viewContext.save()
        dismiss()
    }
}
