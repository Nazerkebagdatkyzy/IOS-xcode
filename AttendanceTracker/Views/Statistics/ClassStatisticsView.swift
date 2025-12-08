//
//  ClassStatisticsView.swift
//  AttendanceTracker
//
//  Created by Nazerke Bagdatkyzy on 05.12.2025.
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

    // --------------- Статистика есептеу ------------------

    private func computeStats() {
        let students: [Student] = {
            if let set = classRoom.students as? Set<Student> {
                return Array(set)
            }
            return []
        }()

        // Барлық attendance жазбаларын тарту
        let req: NSFetchRequest<Attendance> = Attendance.fetchRequest()
        req.predicate = NSPredicate(format: "student.classRoom == %@", classRoom)

        do {
            let all = try viewContext.fetch(req)

            // ----- Күндерді жинау -----
            var daysSet = Set<Date>()
            for a in all {
                if let d = a.date {
                    daysSet.insert(Calendar.current.startOfDay(for: d))
                }
            }
            let totalDays = daysSet.count

            // ----- Күндік summary -----
            var dayCountDict: [Date: Int] = [:]
            for day in daysSet { dayCountDict[day] = 0 }

            for a in all {
                if let d = a.date {
                    let key = Calendar.current.startOfDay(for: d)
                    if a.status == "present" {
                        dayCountDict[key, default: 0] += 1
                    }
                }
            }

            dailySummary = dayCountDict
                .map { ($0.key, $0.value) }
                .sorted { $0.0 < $1.0 }


            // ----- Оқушы бойынша есеп -----
            var stats: [(Student, Int, Int, Double)] = []
            var presentTotal = 0

            for st in students {
                let presentCount = all.filter { $0.student == st && $0.status == "present" }.count
                presentTotal += presentCount

                let percent = totalDays > 0
                    ? (Double(presentCount) / Double(totalDays)) * 100
                    : 0

                stats.append((st, presentCount, totalDays, percent))
            }

            // ----- Сыныптың орташа пайызы -----
            let classPct: Double =
                (totalDays == 0 || students.count == 0)
                ? 0
                : (Double(presentTotal) / Double(totalDays * students.count)) * 100

            studentStats = stats.sorted { $0.3 > $1.3 }
            classPercent = classPct

        } catch {
            print("Ошибка: \(error)")
        }
    }

    // --------------- Көмекші функциялар ------------------

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

