//
//  CoreDataHelpers.swift
//  AttendanceTracke
//
//  Created by Nazerke Bagdatkyzy on 03.12.2025.
//
import Foundation
import CoreData

// MARK: - Group extension
extension Group {

    /// Student-тердің реттелген массиві (SwiftUI үшін)
    var studentsArray: [Student] {
        guard let set = students as? Set<Student> else { return [] }
        return set.sorted { ($0.name ?? "") < ($1.name ?? "") }
    }
}

// MARK: - Student extension
extension Student {

    /// Attendance жазбаларының реттелген массиві
    var attendancesArray: [Attendance] {
       
        let set = attendances as? Set<Attendance> ?? []
        return set.sorted { ($0.date ?? Date()) < ($1.date ?? Date()) }
    }

    func attendanceCount() -> Int {
        attendancesArray.count
    }

    func presentCount() -> Int {
        attendancesArray.filter { $0.isPresent }.count
    }

    func presencePercentage() -> Double {
        let total = attendanceCount()
        if total == 0 { return 0.0 }
        return (Double(presentCount()) / Double(total)) * 100.0
    }
}
