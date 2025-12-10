//
//  StudentStatisticsView.swift
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

            // ===== Жалпы статистика =====
            VStack(alignment: .leading, spacing: 8) {
                Text("Жалпы статистика")
                    .font(.title2)
                    .bold()

                Text("Сабақ күндері: \(totalLessons)")
                Text("Келді: \(presentCount)")
                Text("Келмеді: \(absentCount)")
                
                Text("Қатысу пайызы: \(attendancePercent, specifier: "%.1f")%")
                    .bold()
                    .foregroundColor(.blue)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)

            Divider()

            // ===== Күндер бойынша =====
            Text("Күндер бойынша")
                .font(.headline)

            List {
                ForEach(records, id: \.objectID) { rec in
                    HStack {
                        Text(dateFormat(rec.date ?? Date()))
                        Spacer()
                        Text(rec.isPresent ? "Келді" : "Келмеді")
                            .foregroundColor(rec.isPresent ? .green : .red)
                    }
                }
            }
        }
        .padding()
        .navigationTitle("Статистика")
        .onAppear(perform: loadStats)
    }

    // MARK: - Attendance жүктеу
    private func loadStats() {
        let req: NSFetchRequest<Attendance> = Attendance.fetchRequest()
        req.predicate = NSPredicate(format: "student == %@", student)
        req.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]

        do {
            records = try viewContext.fetch(req)
        } catch {
            print("⚠️ Failed to fetch stats:", error)
            records = []
        }
    }

    // MARK: - Есептелетін мәндер
    private var totalLessons: Int { records.count }
    private var presentCount: Int { records.filter { $0.isPresent }.count }
    private var absentCount: Int { records.filter { !$0.isPresent }.count }

    private var attendancePercent: Double {
        guard totalLessons > 0 else { return 0 }
        return (Double(presentCount) / Double(totalLessons)) * 100
    }

    // MARK: - Көмекші функциялар
    private func dateFormat(_ d: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "dd MMM yyyy"
        return f.string(from: d)
    }
}

