//
//  SchoolStatisticsView.swift
//  AttendanceTracker
//
import SwiftUI
import CoreData

struct SchoolStatisticsView: View {
    @ObservedObject var school: School
    @Environment(\.managedObjectContext) private var viewContext

    @State private var averageAttendance: Double = 0
    @State private var classRatings: [(name: String, percent: Double)] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(school.name ?? "Мектеп")
                    .font(.largeTitle.bold())

                VStack(alignment: .leading, spacing: 8) {
                    Text("Жалпы қатысу пайызы").font(.headline)
                    Text("\(averageAttendance, specifier: "%.1f")%")
                        .font(.system(size: 38, weight: .bold))
                        .foregroundColor(.blue)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)

                Text("Сыныптар бойынша рейтинг").font(.headline)

                if classRatings.isEmpty {
                    Text("Статистика жоқ").foregroundColor(.gray)
                } else {
                    ForEach(classRatings, id: \.name) { item in
                        HStack {
                            Text(item.name)
                            Spacer()
                            Text("\(item.percent, specifier: "%.1f")%").foregroundColor(.blue)
                        }
                        .padding(.vertical, 4)
                    }
                }

                Spacer()
            }
            .padding()
        }
        .onAppear {
            computeSchoolStats()
        }
    }

    private func computeSchoolStats() {
        guard let classSet = school.classes as? Set<ClassRoom>, !classSet.isEmpty else {
            averageAttendance = 0
            classRatings = []
            return
        }

        var totals: [(name: String, percent: Double)] = []
        var sum: Double = 0

        for c in classSet {
            let percent = calculateClassAttendanceUsingFetch(classRoom: c)
            totals.append((name: c.name ?? "Сынып", percent: percent))
            sum += percent
        }

        averageAttendance = totals.isEmpty ? 0 : (sum / Double(totals.count))
        classRatings = totals.sorted { $0.percent > $1.percent }
    }

    // ---- Бұл функция relationship атауына тәуелді емес: Attendance-ті fetch арқылы шығарады ----
    private func calculateClassAttendanceUsingFetch(classRoom: ClassRoom) -> Double {
        let req: NSFetchRequest<Attendance> = Attendance.fetchRequest()
        req.predicate = NSPredicate(format: "classRoom == %@", classRoom)

        do {
            let items = try viewContext.fetch(req)
            guard !items.isEmpty else { return 0 }

            var present = 0.0
            var total = Double(items.count)

            for a in items {
                if a.isPresent {    // ← сендегі нақты поле аты
                    present += 1
                }
            }

            return (present / total) * 100   // пайыз
        }
        catch {
            print("fetch attendance error:", error)
            return 0
        }
    }

}
