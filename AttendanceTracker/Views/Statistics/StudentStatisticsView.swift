//
//  StudentStatisticsView.swift
//  AttendanceTracker
//
//  Created by Nazerke Bagdatkyzy on 05.12.2025.
//
import SwiftUI
import CoreData

struct StudentStatisticsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var student: Student

    @State private var records: [Attendance] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {

            Text(student.name ?? "Оқушы")
                .font(.largeTitle)
                .bold()

            // Summary block
            VStack(alignment: .leading, spacing: 8) {
                Text("Жалпы статистика")
                    .font(.title2)
                    .bold()

                Text("Барлық күндер: \(totalLessons)")
                Text("Келді: \(presentCount)")
                Text("Келмеді: \(absentCount)")
                Text("Кешіккен: \(lateCount)")
                Text("Қатысу пайызы: \(attendancePercent, specifier: "%.1f")%")
                    .bold()
                    .foregroundColor(.blue)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)

            Divider()

            // List of attendance records
            Text("Күндер бойынша")
                .font(.headline)

            List {
                ForEach(records, id: \.objectID) { rec in
                    HStack {
                        Text(dateFormat(rec.date ?? Date()))
                        Spacer()
                        Text(statusText(rec.status ?? "-"))
                            .foregroundColor(colorForStatus(rec.status ?? "-"))
                    }
                }
            }
        }
        .padding()
        .navigationTitle("Статистика")
        .onAppear(perform: loadStats)
    }

    // MARK: - Load attendance records
    private func loadStats() {
        let req: NSFetchRequest<Attendance> = Attendance.fetchRequest()
        req.predicate = NSPredicate(format: "student == %@", student)
        req.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]

        do {
            records = try viewContext.fetch(req)
        } catch {
            print("Failed to fetch stats:", error)
            records = []
        }
    }

    // MARK: - Computed values
    private var totalLessons: Int { records.count }
    private var presentCount: Int { records.filter { $0.status == "present" }.count }
    private var absentCount: Int { records.filter { $0.status == "absent" }.count }
    private var lateCount: Int { records.filter { $0.status == "late" }.count }

    private var attendancePercent: Double {
        guard totalLessons > 0 else { return 0 }
        return (Double(presentCount) / Double(totalLessons)) * 100
    }

    // MARK: - Formatting helpers
    private func dateFormat(_ d: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "dd MMM yyyy"
        return f.string(from: d)
    }

    private func statusText(_ s: String) -> String {
        switch s {
            case "present": return "Келді"
            case "absent": return "Келмеді"
            case "late": return "Кешікті"
            default: return "-"
        }
    }

    private func colorForStatus(_ s: String) -> Color {
        switch s {
            case "present": return .green
            case "absent": return .red
            case "late": return .orange
            default: return .gray
        }
    }
}

