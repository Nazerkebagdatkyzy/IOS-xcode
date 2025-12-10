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

        ZStack {

            // 🌿 Қою пастель жасыл фон (барлық экрандармен бірдей)
            LinearGradient(
                colors: [
                    Color(#colorLiteral(red: 0.78, green: 0.92, blue: 0.88, alpha: 1)),
                    Color(#colorLiteral(red: 0.84, green: 0.95, blue: 0.90, alpha: 1))
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // 🔹 Мектеп аты
                    Text(school.name ?? "Мектеп")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black.opacity(0.9))
                        .padding(.top, 10)

                    // 🔹 Жалпы қатысу карточкасы
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Жалпы қатысу пайызы")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.black.opacity(0.75))

                        Text("\(averageAttendance, specifier: "%.1f")%")
                            .font(.system(size: 42, weight: .bold))
                            .foregroundColor(Color(#colorLiteral(red: 0.10, green: 0.40, blue: 0.35, alpha: 1)))
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(18)
                    .shadow(color: .black.opacity(0.10), radius: 6, y: 4)

                    // 🔹 Рейтинг тақырыбы
                    Text("Сыныптар бойынша рейтинг")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.black.opacity(0.75))

                    if classRatings.isEmpty {

                        // Статистика жоқ карточкасы
                        Text("Статистика жоқ")
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.08), radius: 6, y: 3)

                    } else {

                        VStack(spacing: 12) {
                            ForEach(classRatings, id: \.name) { item in
                                HStack {
                                    // Сынып атауы
                                    Text(item.name)
                                        .font(.system(size: 18, weight: .medium))

                                    Spacer()

                                    // Пайыз
                                    Text("\(item.percent, specifier: "%.1f")%")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(Color(#colorLiteral(red: 0.10, green: 0.40, blue: 0.35, alpha: 1)))
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(14)
                                .shadow(color: .black.opacity(0.06), radius: 4, y: 3)
                            }
                        }
                    }

                    Spacer()
                }
                .padding()
            }
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

    private func calculateClassAttendanceUsingFetch(classRoom: ClassRoom) -> Double {
        let req: NSFetchRequest<Attendance> = Attendance.fetchRequest()
        req.predicate = NSPredicate(format: "classRoom == %@", classRoom)

        do {
            let items = try viewContext.fetch(req)
            guard !items.isEmpty else { return 0 }

            let presentCount = items.filter { $0.isPresent }.count
            return (Double(presentCount) / Double(items.count)) * 100

        } catch {
            print("fetch attendance error:", error)
            return 0
        }
    }
}

