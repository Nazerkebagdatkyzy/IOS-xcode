//
//  ClassStatisticsView.swift
//  AttendanceTracker
//

import SwiftUI
import CoreData

struct ClassStatisticsView: View {

    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var classRoom: ClassRoom

    @State private var studentStats: [(student: Student,
                                       presentCount: Int,
                                       totalDays: Int,
                                       percent: Double)] = []

    @State private var classPercent: Double = 0.0
    @State private var selectedRange: StatRange = .week

    // ======================================================
    // MARK: - Диапазон
    // ======================================================

    enum StatRange: String, CaseIterable, Identifiable {
        case week = "Апта"
        case month = "Ай"
        case quarter = "Тоқсан"

        var id: String { rawValue }
    }

    // ======================================================
    // MARK: - UI
    // ======================================================

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                // 🔹 Диапазон таңдау
                Picker("Диапазон", selection: $selectedRange) {
                    ForEach(StatRange.allCases) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .onChange(of: selectedRange) { _ in
                    computeStudentStats()
                }

                // 🔹 Сыныптың орташа пайызы
                VStack(spacing: 6) {
                    Text("Сыныптың орташа қатысуы")
                        .font(.headline)

                    Text(percentageString(classPercent))
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.blue)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(14)

                // 🔹 Сынып атауы
                Text("Сынып: \(classRoom.name ?? "—")")
                    .font(.title2)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("Оқушылардың қатысу статистикасы")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // 🔹 Оқушылар
                ForEach(studentStats, id: \.student.objectID) { item in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.student.name ?? "—")
                                .font(.body)

                            Text("Келді: \(item.presentCount) / \(item.totalDays)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        Text(percentageString(item.percent))
                            .font(.headline)
                            .foregroundColor(item.percent >= 75 ? .green : .red)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 3)
                }

                if studentStats.isEmpty {
                    Text("Статистика жоқ")
                        .foregroundColor(.gray)
                        .italic()
                        .padding(.top, 20)
                }
            }
            .padding()
        }
        .navigationTitle("Статистика")
        .onAppear {
            computeStudentStats()
        }
    }

    // ======================================================
    // MARK: - НЕГІЗГІ ЛОГИКА (ДҰРЫС)
    // ======================================================

    private func computeStudentStats() {

        let students: [Student] =
            (classRoom.students as? Set<Student>)?
            .sorted { $0.studentNumber < $1.studentNumber } ?? []

        let range = dateRange()

        let req: NSFetchRequest<Attendance> = Attendance.fetchRequest()
        req.predicate = NSPredicate(
            format: "classRoom == %@ AND date >= %@ AND date < %@",
            classRoom,
            range.start as NSDate,
            range.end as NSDate
        )

        do {
            let records = try viewContext.fetch(req)

            // 🔹 нақты өткізілген күндер
            let days = Set(
                records.compactMap {
                    Calendar.current.startOfDay(for: $0.date ?? Date())
                }
            )

            let totalDays = days.count
            guard totalDays > 0 else {
                studentStats = []
                classPercent = 0
                return
            }

            var result: [(Student, Int, Int, Double)] = []

            for student in students {

                // 🔹 студенттің нақты келген күндері
                let presentDays = Set(
                    records
                        .filter { $0.student == student && $0.isPresent }
                        .compactMap {
                            Calendar.current.startOfDay(for: $0.date ?? Date())
                        }
                )

                let presentCount = presentDays.count
                let percent = (Double(presentCount) / Double(totalDays)) * 100

                result.append((student, presentCount, totalDays, percent))
            }

            studentStats = result.sorted { $0.3 > $1.3 }

            // ⭐ СЫНЫПТЫҢ ОРТАША ПАЙЫЗЫ
            let totalPresent = result.reduce(0) { $0 + $1.1 }
            let totalPossible = totalDays * students.count

            classPercent = totalPossible > 0
                ? (Double(totalPresent) / Double(totalPossible)) * 100
                : 0

        } catch {
            print("❌ STAT ERROR:", error.localizedDescription)
        }
    }

    // ======================================================
    // MARK: - Көмекші функциялар
    // ======================================================

    private func percentageString(_ value: Double) -> String {
        String(format: "%.1f%%", value)
    }

    private func lastAttendanceDate() -> Date {
        let req: NSFetchRequest<Attendance> = Attendance.fetchRequest()
        req.predicate = NSPredicate(format: "classRoom == %@", classRoom)
        req.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        req.fetchLimit = 1

        let last = try? viewContext.fetch(req).first?.date
        return Calendar.current.startOfDay(for: last ?? Date())
    }

    private func dateRange() -> (start: Date, end: Date) {
        let calendar = Calendar.current

        // ✅ соңғы сақталған күнге дейін ғана
        let end = lastAttendanceDate()
            .addingTimeInterval(60 * 60 * 24)

        let start: Date
        switch selectedRange {
        case .week:
            start = calendar.date(byAdding: .day, value: -7, to: end)!
        case .month:
            start = calendar.date(byAdding: .month, value: -1, to: end)!
        case .quarter:
            start = calendar.date(byAdding: .month, value: -3, to: end)!
        }

        return (start, end)
    }
}

