//
//  Attendance+CoreDataProperties.swift
//  AttendanceTracke
//
//  Created by Nazerke Bagdatkyzy on 02.12.2025.
//

import Foundation
import CoreData

extension Attendance {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Attendance> {
        return NSFetchRequest<Attendance>(entityName: "Attendance")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var date: Date?
    @NSManaged public var isPresent: Bool
    @NSManaged public var student: Student?
}

extension Attendance: Identifiable { }
