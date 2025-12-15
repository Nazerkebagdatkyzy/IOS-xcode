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
    @State private var tempPresence: [NSManagedObjectID: Bool] = [:]
    @State private var tardyMinutes: [NSManagedObjectID: Int] = [:]
    @State private var tardyReason: [NSManagedObjectID: String] = [:]

    @State private var saving = false
    @State private var showSavedAlert = false


    // ------------------------------
    // СТУДЕНТТЕР
    // ------------------------------
    private var students: [Student] {
        if let set = classRoom.students as? Set<Student> {
            return set.sorted { $0.studentNumber < $1.studentNumber }
        }
        return []
    }

    var body: some View {
        Form {

            // ------------------------------
            // КҮН
            // ------------------------------
            Section(header: Text("Күн")) {
                DatePicker("Күнді таңдаңыз", selection: $date, displayedComponents: .date)
                    .onChange(of: date) { _ in
                        loadExistingForDate()
                    }
            }

            // ------------------------------
            // ОҚУШЫЛАР
            // ------------------------------
            Section(header: Text("Сынып: \(classRoom.name ?? "") — Оқушылар")) {
                ForEach(students, id: \.objectID) { student in
                    StudentAttendanceRow(
                        student: student,
                        isPresent: Binding(
                            get: { tempPresence[student.objectID] ?? true },
                            set: { tempPresence[student.objectID] = $0 }
                        ),
                        tardyMinutes: Binding(
                            get: { tardyMinutes[student.objectID] ?? 0 },
                            set: { tardyMinutes[student.objectID] = $0 }
                        ),
                        tardyReason: Binding(
                            get: { tardyReason[student.objectID] ?? "" },
                            set: { tardyReason[student.objectID] = $0 }
                        )
                    )
                }

                .onDelete(perform: deleteStudents)
            }

            // ------------------------------
            // ТҮЙМЕЛЕР
            // ------------------------------
            Section {
                Button("Барлығын КЕЛДІ қылу") {
                    students.forEach {
                        tempPresence[$0.objectID] = true
                        tardyMinutes[$0.objectID] = 0
                        tardyReason[$0.objectID] = ""
                    }
                }

                Button(action: saveAttendance) {
                    if saving {
                        ProgressView()
                    } else {
                        Text("Сақтау").bold()
                    }
                }
                .disabled(saving)


            }
        }
        .navigationTitle("Attendance — \(classRoom.name ?? "")")
        .onAppear {
            loadExistingForDate()
        }
        .alert("Сақталды!", isPresented: $showSavedAlert) {
            Button("OK") {}
        }
        .toolbar {
            NavigationLink(destination: ClassStatisticsView(classRoom: classRoom)) {
                Image(systemName: "chart.bar.fill")
            }
        }
    }

    // ------------------------------
    // КҮН БАСТАУЫ
    // ------------------------------
    private func startOfDay(_ date: Date) -> Date {
        Calendar.current.startOfDay(for: date)
    }

    // ------------------------------
    // ЖҮКТЕУ
    // ------------------------------
    private func loadExistingForDate() {

        let dayStart = startOfDay(date)
        let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: dayStart)!

        let req: NSFetchRequest<Attendance> = Attendance.fetchRequest()
        req.predicate = NSPredicate(
            format: "classRoom == %@ AND date >= %@ AND date < %@",
            classRoom, dayStart as CVarArg, nextDay as CVarArg
        )

        let list = (try? viewContext.fetch(req)) ?? []

        for student in students {
            if let att = list.first(where: { $0.student == student }) {
                tempPresence[student.objectID] = att.isPresent
                tardyMinutes[student.objectID] = Int(att.tardyMinutes)
                tardyReason[student.objectID] = att.tardyReason ?? ""
            } else {
                tempPresence[student.objectID] = true
                tardyMinutes[student.objectID] = 0
                tardyReason[student.objectID] = ""
            }
        }
    }

    // ------------------------------
    // САҚТАУ
    // ------------------------------
    private func saveAttendance() {
        saving = true

        let dayStart = startOfDay(date)
        let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: dayStart)!

        for student in students {

            let isPresent = tempPresence[student.objectID] ?? true
            let minutes = tardyMinutes[student.objectID] ?? 0
            let reason = tardyReason[student.objectID]

            let req: NSFetchRequest<Attendance> = Attendance.fetchRequest()
            req.predicate = NSPredicate(
                format: "student == %@ AND classRoom == %@ AND date >= %@ AND date < %@",
                student, classRoom, dayStart as CVarArg, nextDay as CVarArg
            )
            req.fetchLimit = 1

            let existing = try? viewContext.fetch(req).first

            let att = existing ?? Attendance(context: viewContext)
            att.id = att.id ?? UUID()
            att.student = student
            att.classRoom = classRoom
            att.date = dayStart
            att.isPresent = isPresent
            att.tardyMinutes = Int16(minutes)
            att.tardyReason = reason

            if !isPresent {
                NotificationService.notifyAbsent(
                    studentName: student.name ?? "Оқушы",
                    className: classRoom.name ?? ""
                )
            }
        }

        try? viewContext.save()
        saving = false
        showSavedAlert = true
    }

    // ------------------------------
    // ӨШІРУ
    // ------------------------------
    private func deleteStudents(at offsets: IndexSet) {
        let list = students
        offsets.map { list[$0] }.forEach { student in
            viewContext.delete(student)
        }
        try? viewContext.save()
    }
    

}

