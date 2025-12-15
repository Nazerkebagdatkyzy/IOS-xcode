//
//  StudentHistoryView.swift
//  AttendanceTracker
//
//  Created by Nazerke Bagdatkyzy on 11.12.2025.
//
import SwiftUI
import CoreData

struct StudentHistoryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var student: Student

    @State private var records: [Attendance] = []

    @State private var classDays: [Date] = []
    @State private var studentRecords: [Date: Attendance] = [:]

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {

                ForEach(records, id: \.objectID) { rec in

                    VStack(alignment: .leading, spacing: 6) {

                        // 📅 КҮН + STATUS
                        HStack {
                            Text(dateFormat(rec.date ?? Date()))
                                .font(.body)

                            Spacer()

                            Text(rec.isPresent ? "Келді" : "Келмеді")
                                .font(.body.bold())
                                .foregroundColor(rec.isPresent ? .green : .red)
                        }

                        // ⏱ КЕШІГУ
                        if rec.tardyMinutes > 0 {
                            Text("Кешігу: \(rec.tardyMinutes) мин")
                                .font(.caption)
                                .foregroundColor(.orange)

                            if let reason = rec.tardyReason, !reason.isEmpty {
                                Text("Себебі: \(reason)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                }

                if records.isEmpty {
                    Text("Мәлімет жоқ")
                        .foregroundColor(.gray)
                        .italic()
                        .padding(.top)
                }
            }

            .padding()
        }
        .navigationTitle("Қатысу тарихы")
        .onAppear(perform: loadHistory)
    }

    // MARK: - Attendance жүктеу
    private func loadHistory() {

        let req: NSFetchRequest<Attendance> = Attendance.fetchRequest()
        req.predicate = NSPredicate(
            format: "student == %@",
            student
        )
        req.sortDescriptors = [
            NSSortDescriptor(key: "date", ascending: false)
        ]

        let records = (try? viewContext.fetch(req)) ?? []
        self.records = records

        // 🔵 КҮНДЕРДІ ТЕК ATTENDANCE БАР КҮНДЕРДЕН АЛАМЫЗ
        classDays = records.compactMap {
            Calendar.current.startOfDay(for: $0.date ?? Date())
        }

        // 🔵 Dictionary: күн → attendance
        studentRecords = Dictionary(
            uniqueKeysWithValues: records.map {
                (Calendar.current.startOfDay(for: $0.date ?? Date()), $0)
            }
        )
    }


    // MARK: Мәндер
    private var totalLessons: Int { classDays.count }
    private var presentCount: Int { records.filter { $0.isPresent }.count }
    private var absentCount: Int { totalLessons - presentCount }


    // MARK: - Көмекші
    private func dateFormat(_ d: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "dd MMM yyyy"
        return f.string(from: d)
    }
}

