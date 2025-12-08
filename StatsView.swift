//
//  StatsView.swift
//  AttendanceTracke
//
//  Created by Nazerke Bagdatkyzy on 28.11.2025.
//
import SwiftUI

struct StatsView: View {
    @ObservedObject var group: Group
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Топ")) {
                    Text(group.name ?? "")
                }

                Section(header: Text("Студенттер қатысу пайызы")) {
                    ForEach(group.studentsArray) { student in
                        HStack {
                            Text(student.name ?? "")
                            Spacer()
                            Text(String(format: "%.0f%%", student.presencePercentage()))
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Section(header: Text("Орташа келу пайызы")) {
                    Text(String(format: "%.0f%%", groupAverage()))
                        .font(.title2)
                }
            }
            .navigationTitle("Статистика")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Жабу") { dismiss() }
                }
            }
        }
    }

    private func groupAverage() -> Double {
        let students = group.studentsArray
        if students.isEmpty { return 0.0 }
        let sums = students.map { $0.presencePercentage() }.reduce(0, +)
        return sums / Double(students.count)
    }
}


