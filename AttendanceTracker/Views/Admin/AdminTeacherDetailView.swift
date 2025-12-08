//
//  AdminTeacherDetailView.swift
//  AttendanceTracker
//
//  Created by Nazerke Bagdatkyzy on 05.12.2025.
//
import SwiftUI

struct AdminTeacherDetailView: View {
    @ObservedObject var teacher: Teacher

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Аты: \(teacher.name ?? "-")")
            Text("Email: \(teacher.email ?? "-")")

            Spacer()
        }
        .padding()
        .navigationTitle("Мұғалім")
    }
}
