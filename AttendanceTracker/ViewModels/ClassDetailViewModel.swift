//
//  ClassDetailViewModel.swift
//  AttendanceTracker
//
//  Created by Nazerke Bagdatkyzy on 17.12.2025.
//
import Foundation
import CoreData
import Combine


final class ClassDetailViewModel: ObservableObject {

    @Published var date = Date()
    @Published var tempPresence: [NSManagedObjectID: Bool] = [:]
    @Published var tardyMinutes: [NSManagedObjectID: Int] = [:]
    @Published var tardyReason: [NSManagedObjectID: String] = [:]

    @Published var saving = false
    @Published var showSavedAlert = false

    private let context: NSManagedObjectContext
    private let classRoom: ClassRoom
    let students: [Student]

    init(classRoom: ClassRoom, context: NSManagedObjectContext) {
        self.classRoom = classRoom
        self.context = context

        if let set = classRoom.students as? Set<Student> {
            self.students = set.sorted { $0.studentNumber < $1.studentNumber }
        } else {
            self.students = []
        }

        loadExisting()
    }

    // MARK: - Helpers
    private func startOfDay(_ date: Date) -> Date {
        Calendar.current.startOfDay(for: date)
    }

    // MARK: - Load
    func loadExisting() {
        let dayStart = startOfDay(date)
        let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: dayStart)!

        let req: NSFetchRequest<Attendance> = Attendance.fetchRequest()
        req.predicate = NSPredicate(
            format: "classRoom == %@ AND date >= %@ AND date < %@",
            classRoom, dayStart as CVarArg, nextDay as CVarArg
        )

        let list = (try? context.fetch(req)) ?? []

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

    // MARK: - Save
    func saveAttendance() {
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

            let existing = try? context.fetch(req).first
            let att = existing ?? Attendance(context: context)

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

        try? context.save()
        saving = false
        showSavedAlert = true
    }
}

