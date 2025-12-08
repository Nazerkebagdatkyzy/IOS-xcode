//
//  ClassDetailView.swift
//  AttendanceTracker
//
//  Created by Nazerke Bagdatkyzy on 05.12.2025.
// ClassAttendanceView.swift
//

import SwiftUI
import CoreData

struct ClassDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var classRoom: ClassRoom

    @State private var date = Date()
    @State private var tempStatuses: [NSManagedObjectID: AttendanceStatus] = [:]
    @State private var saving = false
    @State private var showSavedAlert = false

    private var students: [Student] {
        if let set = classRoom.students as? Set<Student> {
            return Array(set).sorted { ($0.name ?? "") < ($1.name ?? "") }
        }
        return []
    }

    var body: some View {
        VStack {
            Form {
                // ===== Күнді таңдау =====
                Section(header: Text("Күн")) {
                    DatePicker("Күнді таңдаңыз", selection: $date, displayedComponents: .date)
                }

                // ===== Оқушылар тізімі =====
                Section(header: Text("Сынып: \(classRoom.name ?? "") — Оқушылар")) {
                    ForEach(students, id: \.objectID) { student in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(student.name ?? "Аты жоқ")
                                let num = student.studentNumber
                                Text("№\(num)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)

                            }

                            Spacer()

                            // ===== Статус таңдау =====
                            Picker("", selection: Binding(
                                get: { tempStatuses[student.objectID] ?? .present },
                                set: { tempStatuses[student.objectID] = $0 }
                            )) {
                                ForEach(AttendanceStatus.allCases, id: \.self) { s in
                                    Text(s.display).tag(s)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                    }
                }

                // ===== Түймелер =====
                Section {
                    Button(action: markAllPresent) {
                        Text("Барлығын 'Келді' қылу")
                            .frame(maxWidth: .infinity)
                    }

                    Button(action: saveAttendance) {
                        if saving {
                            ProgressView().frame(maxWidth: .infinity)
                        } else {
                            Text("Сақтау").frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(saving)
                }
            }
        }
        .navigationTitle("Attendance — \(classRoom.name ?? "")")
        .onAppear(perform: loadExistingForDate)
        .alert(isPresented: $showSavedAlert) {
            Alert(
                title: Text("Сақталды"),
                message: Text("Attendance жазбалары сақталды"),
                dismissButton: .default(Text("OK"))
            )
        }

        // ===== НАВИГАЦИЯҒА СТАТИСТИКА ҚОСТЫМ =====
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: ClassStatisticsView(classRoom: classRoom)) {
                    Image(systemName: "chart.bar.fill")
                        .foregroundColor(.blue)
                }
            }
        }
    }

    // ===== Күннің басын анықтау =====
    private func startOfDay(_ d: Date) -> Date {
        Calendar.current.startOfDay(for: d)
    }

    // ===== Бар attendance жүктеу =====
    private func loadExistingForDate() {
        tempStatuses = [:]
        for s in students { tempStatuses[s.objectID] = .present }

        let req: NSFetchRequest<Attendance> = Attendance.fetchRequest()
        let dayStart = startOfDay(date)
        let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: dayStart)!

        req.predicate = NSPredicate(
            format: "student.classRoom == %@ AND date >= %@ AND date < %@",
            classRoom, dayStart as CVarArg, nextDay as CVarArg
        )

        do {
            let arr = try viewContext.fetch(req)
            for a in arr {
                if let stu = a.student {
                    let id = stu.objectID
                    if let statusStr = a.status,
                       let st = AttendanceStatus(rawValue: statusStr) {
                        tempStatuses[id] = st
                    }
                }
            }
        } catch {
            print("Failed to fetch existing attendance:", error)
        }
    }

    // ===== Барлығын КЕЛДІ ету =====
    private func markAllPresent() {
        for s in students { tempStatuses[s.objectID] = .present }
    }

    // ===== Attendance сақтау =====
    private func saveAttendance() {
        saving = true
        let dayStart = startOfDay(date)
        let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: dayStart)!

        for student in students {
            guard let status = tempStatuses[student.objectID] else { continue }

            let req: NSFetchRequest<Attendance> = Attendance.fetchRequest()
            req.predicate = NSPredicate(
                format: "student == %@ AND date >= %@ AND date < %@",
                student, dayStart as CVarArg, nextDay as CVarArg
            )
            req.fetchLimit = 1

            do {
                let found = try viewContext.fetch(req)

                if let att = found.first {
                    att.status = status.rawValue
                    att.date = date
                } else {
                    let att = Attendance(context: viewContext)
                    att.id = UUID()
                    att.date = date
                    att.status = status.rawValue
                    att.student = student
                }
            } catch {
                print("fetch error:", error)
            }
        }

        do {
            try viewContext.save()
            showSavedAlert = true
        } catch {
            print("Save error:", error)
        }

        saving = false
    }
}
