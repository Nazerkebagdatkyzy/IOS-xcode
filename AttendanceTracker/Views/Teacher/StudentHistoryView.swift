//
//  StudentHistoryView.swift
//  AttendanceTracker
//

import SwiftUI
import CoreData

struct StudentHistoryView: View {

    @ObservedObject var student: Student
    @Environment(\.managedObjectContext) private var viewContext

    @State private var records: [Attendance] = []

    // MARK: - Summary
    private var presentCount: Int {
        records.filter { $0.isPresent && $0.tardyMinutes == 0 }.count
    }

    private var tardyCount: Int {
        records.filter { $0.tardyMinutes > 0 }.count
    }

    private var absentCount: Int {
        records.filter { !$0.isPresent }.count
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {

                // 🔵 Аты
                Text(student.name ?? "Оқушы")
                    .font(.largeTitle)
                    .bold()

                // 🔵 Summary
                VStack(alignment: .leading, spacing: 6) {
                    Text("Қатысу қорытындысы")
                        .font(.title2)
                        .bold()

                    Text("Келген: \(presentCount)")
                    Text("Кешіккен: \(tardyCount)")
                    Text("Келмеген: \(absentCount)")
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)

                Divider()

                // 🔵 History
                VStack(alignment: .leading, spacing: 12) {
                    Text("Қатысу тарихы")
                        .font(.title2)
                        .bold()

                    ForEach(records, id: \.objectID) { att in
                        AttendanceHistoryRow(attendance: att)
                    }
                }
            }
            .padding()
        }
        .onAppear {
            fetchHistory()
        }
        .navigationTitle("History")
    }

    // MARK: - Fetch
    private func fetchHistory() {
        let req: NSFetchRequest<Attendance> = Attendance.fetchRequest()
        req.predicate = NSPredicate(format: "student == %@", student)
        req.sortDescriptors = [
            NSSortDescriptor(key: "date", ascending: false)
        ]

        records = (try? viewContext.fetch(req)) ?? []
    }
}
