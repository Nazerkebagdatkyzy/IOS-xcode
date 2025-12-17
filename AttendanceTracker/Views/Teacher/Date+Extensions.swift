//
//  Date+Extensions.swift
//  AttendanceTracker
//
//  Created by Nazerke Bagdatkyzy on 17.12.2025.
//

import Foundation

extension Date {
    func startOfDay() -> Date {
        Calendar.current.startOfDay(for: self)
    }
}
