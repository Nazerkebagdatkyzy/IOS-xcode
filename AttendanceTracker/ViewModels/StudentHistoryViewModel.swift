//
//  StudentHistoryViewModel.swift
//  AttendanceTracker
//
//  Created by Nazerke Bagdatkyzy on 17.12.2025.
//
import Foundation
import CoreData
import Combine


final class StudentHistoryViewModel: ObservableObject {

    @Published var records: [Attendance] = []

    private let context: NSManagedObjectContext
    private let student: Student

    init(student: Student, context: NSManagedObjectContext) {
        self.student = student
        self.context = context
        fetch()
    }

    func fetch() {
        let req: NSFetchRequest<Attendance> = Attendance.fetchRequest()
        req.predicate = NSPredicate(format: "student == %@", student)
        req.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        records = (try? context.fetch(req)) ?? []
    }
}

