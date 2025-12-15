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
            VStack(alignment: .leading, spacing: 22) {

                // 🔵 Оқушы аты
                Text(student.name ?? "Оқушы")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)

                // 🔵 Қатысу қорытындысы
                VStack(alignment: .leading, spacing: 8) {
                    Text("Қатысу қорытындысы")
                        .font(.title2).bold()

                    Text("Қатысқан күндер: \(presentCount)")
                    Text("Қатыспаған күндер: \(absentCount)")
                    Text("Барлық сабақ күндері: \(totalLessons)")
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(14)

                Divider().padding(.vertical, 4)

                // 🔵 Сабақ күндері бойынша тізім
                Text("Күндер бойынша")
                    .font(.headline)

                VStack(spacing: 12) {

                    ForEach(classDays, id: \.self) { day in

                        let record = studentRecords[day]
                        let isPresent = record?.isPresent ?? false

                        HStack {
                            Text(dateFormat(day))

                            Spacer()

                            Text(isPresent ? "Келді" : "Келмеді")
                                .foregroundColor(isPresent ? .green : .red)
                                .bold()
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                    }


                    if records.isEmpty {
                        Text("Мәлімет жоқ")
                            .foregroundColor(.gray)
                            .italic()
                            .padding(.top)
                    }
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

