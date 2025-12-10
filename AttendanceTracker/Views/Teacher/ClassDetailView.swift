//
//  ClassDetailView.swift
//  AttendanceTracker
//

import SwiftUI
import CoreData

struct ClassDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var classRoom: ClassRoom

    @State private var date = Date()
    @State private var tempPresence: [NSManagedObjectID : Bool] = [:]   // ← ТЕК isPresent
    @State private var saving = false
    @State private var showSavedAlert = false

    // ------------------------------
    // СТУДЕНТТЕР ТІЗІМІ
    // ------------------------------
    private var students: [Student] {
        if let set = classRoom.students as? Set<Student> {
            return Array(set).sorted { ($0.name ?? "") < ($1.name ?? "") }
        }
        return []
    }

    var body: some View {
        VStack {
            Form {
                // ------------------------------
                // КҮН ТАҢДАУ
                // ------------------------------
                Section(header: Text("Күн")) {
                    DatePicker("Күнді таңдаңыз", selection: $date, displayedComponents: .date)
                        .onChange(of: date) { _ in loadExistingForDate() }
                }

                // ------------------------------
                // ОҚУШЫЛАР ТІЗІМІ — КЕЛДІ / КЕЛМЕДІ
                // ------------------------------
                Section(header: Text("Сынып: \(classRoom.name ?? "") — Оқушылар")) {
                    ForEach(students, id: \.objectID) { student in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(student.name ?? "Аты жоқ")
                                Text("№\(student.studentNumber)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            // ---------- КЕЛДІ ----------
                            Button(action: {
                                tempPresence[student.objectID] = true
                            }) {
                                Text("Келді")
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        (tempPresence[student.objectID] ?? true)
                                        ? Color.green.opacity(0.9)
                                        : Color.gray.opacity(0.25)
                                    )
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }

                            // ---------- КЕЛМЕДІ ----------
                            Button(action: {
                                tempPresence[student.objectID] = false
                            }) {
                                Text("Келмеді")
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        !(tempPresence[student.objectID] ?? true)
                                        ? Color.red.opacity(0.9)
                                        : Color.gray.opacity(0.25)
                                    )
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.vertical, 4)

                    }
                }

                // ------------------------------
                // ТҮЙМЕЛЕР
                // ------------------------------
                Section {
                    Button("Барлығын КЕЛДІ қылу") {
                        markAllPresent()
                    }

                    Button(action: saveAttendance) {
                        saving
                        ? AnyView(ProgressView())
                        : AnyView(Text("Сақтау").bold())
                    }
                    .disabled(saving)
                }
            }
        }
        .navigationTitle("Attendance — \(classRoom.name ?? "")")
        .onAppear { loadExistingForDate() }
        .alert("Сақталды!", isPresented: $showSavedAlert) {
            Button("OK") {}
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: ClassStatisticsView(classRoom: classRoom)) {
                    Image(systemName: "chart.bar.fill")
                        .foregroundColor(.blue)
                }
            }
        }
    }

    // ------------------------------
    // КҮН БАСТАУЫН АЛУ
    // ------------------------------
    private func startOfDay(_ d: Date) -> Date {
        Calendar.current.startOfDay(for: d)
    }

    // ------------------------------
    // БЕЛГІЛІ КҮННІҢ ATTENDANCE-ЫН ЖҮКТЕУ
    // ------------------------------
    private func loadExistingForDate() {
        tempPresence = [:]

        let req: NSFetchRequest<Attendance> = Attendance.fetchRequest()
        let dayStart = startOfDay(date)
        let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: dayStart)!

        req.predicate = NSPredicate(
            format: "classRoom == %@ AND date >= %@ AND date < %@",
            classRoom, dayStart as CVarArg, nextDay as CVarArg
        )

        do {
                let list = try viewContext.fetch(req)

                for student in students {
                    if let att = list.first(where: { $0.student == student }) {
                        tempPresence[student.objectID] = att.isPresent
                    } else {
                        tempPresence[student.objectID] = true   // default = present (OK)
                    }
                }
        } catch {
            print("ERROR loading attendance:", error)
        }
    }

    // ------------------------------
    // БАРЛЫҒЫН КЕЛДІ ҚЫЛУ
    // ------------------------------
    private func markAllPresent() {
        students.forEach { tempPresence[$0.objectID] = true }
    }

    // ------------------------------
    // ATTENDANCE САҚТАУ
    // ------------------------------
    private func saveAttendance() {
        saving = true

        let dayStart = startOfDay(date)
        let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: dayStart)!

        for student in students {
            let isPresent = tempPresence[student.objectID] ?? true

            let req: NSFetchRequest<Attendance> = Attendance.fetchRequest()
            req.predicate = NSPredicate(
                format: "student == %@ AND date >= %@ AND date < %@",
                student, dayStart as CVarArg, nextDay as CVarArg
            )
            req.fetchLimit = 1

            do {
                let found = try viewContext.fetch(req)

                if let att = found.first {
                    att.isPresent = isPresent
                    att.date = date
                } else {
                    let att = Attendance(context: viewContext)
                    att.id = UUID()
                    att.student = student
                    att.classRoom = classRoom
                    att.date = date
                    att.isPresent = isPresent
                }

            } catch {
                print("Fetch error:", error)
            }
        }

        do {
            try viewContext.save()
        } catch {
            print("Save error:", error)
        }

        saving = false
        showSavedAlert = true
    }
}

