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
                    ForEach(records, id: \.objectID) { rec in
                        HStack {
                            Text(dateFormat(rec.date ?? Date()))
                                .font(.body)

                            Spacer()

                            Text(rec.isPresent ? "Келді" : "Келмеді")
                                .font(.body.bold())
                                .foregroundColor(rec.isPresent ? .green : .red)
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
            }
            .padding()
        }
        .navigationTitle("Қатысу тарихы")
        .onAppear(perform: loadHistory)
    }

    // MARK: - Attendance жүктеу
    private func loadHistory() {
        let req: NSFetchRequest<Attendance> = Attendance.fetchRequest()
        req.predicate = NSPredicate(format: "student == %@", student)
        req.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]

        do {
            records = try viewContext.fetch(req)
        } catch {
            print("⚠️ Қате:", error)
            records = []
        }
    }

    // MARK: Мәндер
    private var totalLessons: Int { records.count }
    private var presentCount: Int { records.filter { $0.isPresent }.count }
    private var absentCount: Int { records.filter { !$0.isPresent }.count }

    // MARK: - Көмекші
    private func dateFormat(_ d: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "dd MMM yyyy"
        return f.string(from: d)
    }
}

