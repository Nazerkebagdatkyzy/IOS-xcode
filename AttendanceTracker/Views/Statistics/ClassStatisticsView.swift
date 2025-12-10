//
//  ClassStatisticsView.swift
//  AttendanceTracker
//

import SwiftUI
import CoreData

struct ClassStatisticsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var classRoom: ClassRoom

    @State private var studentStats: [(student: Student, presentCount: Int, totalDays: Int, percent: Double)] = []
    @State private var classPercent: Double = 0.0
    @State private var dailySummary: [(day: Date, presentCount: Int)] = []

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {

                // ------- Сынып атауы -------
                Text("Сынып: \(classRoom.name ?? "—")")
                    .font(.title2).bold()
                    .padding(.top)

                // ------- Жалпы пайызы -------
                VStack(alignment: .leading, spacing: 8) {
                    Text("Орташа қатысу")
                        .font(.headline)
                    Text(percentageString(classPercent))
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.blue)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)


                // ------- Оқушылар бойынша -------
                VStack(alignment: .leading, spacing: 10) {

                    Text("Оқушылардың қатысу көрсеткіштері")
                        .font(.headline)

                    ForEach(studentStats, id: \.student.objectID) { item in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(item.student.name ?? "—")
                                Text("Келді: \(item.presentCount) / \(item.totalDays)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text(percentageString(item.percent))
                                .bold()
                        }
                        .padding(10)
                        .background(Color(.systemBackground))
                        .cornerRadius(8)
                        .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
                    }

                    if studentStats.isEmpty {
                        Text("Статистика жоқ — әлі жазбалар жоқ")
                            .foregroundColor(.gray)
                            .italic()
                    }
                }
                .padding(.horizontal)


                // ------- Күндер бойынша -------
                VStack(alignment: .leading, spacing: 12) {
                    Text("Күндер бойынша қатысу")
                        .font(.headline)

                    ForEach(dailySummary, id: \.day) { item in
                        HStack {
                            Text(formatDate(item.day))
                                .frame(width: 100, alignment: .leading)

                            ProgressView(value: Double(item.presentCount), total: Double(maxStudents))
                                .frame(height: 12)

                            Text("\(item.presentCount)/\(maxStudents)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(width: 70, alignment: .trailing)
                        }
                    }

                    if dailySummary.isEmpty {
                        Text("Күндік жазбалар жоқ")
                            .foregroundColor(.gray)
                            .italic()
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Статистика")
        .onAppear(perform: computeStats)
    }


    // ======================================================
    // MARK: - Статистика есептеу
    // ======================================================

    private func computeStats() {
        // ---- 1. Сыныптағы студенттер ----
        let students: [Student] = (classRoom.students as? Set<Student>)?.sorted {
            $0.studentNumber < $1.studentNumber
        } ?? []

        // ---- 2. Attendance жазбаларын жинaу ----
        let req: NSFetchRequest<Attendance> = Attendance.fetchRequest()
        req.predicate = NSPredicate(format: "classRoom == %@", classRoom)

        do {
            let all = try viewContext.fetch(req)

            // ---- 3. Күндерді анықтау ----
            let days = Array(
                Set(all.compactMap { Calendar.current.startOfDay(for: $0.date ?? Date()) })
            ).sorted()

            let totalDays = days.count
            let studentCount = students.count

            // Егер күн жоқ → статистика жоқ
            guard totalDays > 0, studentCount > 0 else {
                classPercent = 0
                studentStats = []
                dailySummary = []
                return
            }

            // ---- 4. Күндер бойынша (dailySummary) ----
            var dailyDict: [(Date, Int)] = []

            for day in days {
                // сол күндегі "present" саны
                let count = all.filter {
                    Calendar.current.startOfDay(for: $0.date ?? Date()) == day && $0.isPresent
                }.count

                dailyDict.append((day, count))
            }

            dailySummary = dailyDict

            // ---- 5. Оқушы бойынша статистика ----
            var stats: [(Student, Int, Int, Double)] = []
            var totalPresent = 0

            for st in students {
                // Берілген студенттің қатысу саны
                let presentCount = all.filter { $0.student == st && $0.isPresent }.count
                totalPresent += presentCount

                // Пайыздық көрсеткіш
                let percent = (Double(presentCount) / Double(totalDays)) * 100

                stats.append((st, presentCount, totalDays, percent))
            }

            studentStats = stats.sorted { $0.3 > $1.3 }

            // ---- 6. Сыныптың орташа пайызы ----
            classPercent = Double(totalPresent) /
                           Double(totalDays * studentCount) * 100

        } catch {
            print("⚠️ ERROR:", error.localizedDescription)
        }
    }


    // ======================================================
    // MARK: - Көмекші функциялар
    // ======================================================

    private var maxStudents: Int {
        if let set = classRoom.students as? Set<Student> {
            return set.count
        }
        return 0
    }

    private func percentageString(_ v: Double) -> String {
        String(format: "%.1f%%", v)
    }

    private func formatDate(_ d: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "dd MMM"
        return f.string(from: d)
    }
}

