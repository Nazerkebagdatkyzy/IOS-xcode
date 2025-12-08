//
//  AttendanceTrackerApp.swift
//  AttendanceTracke
//
//  Created by Nazerke Bagdatkyzy on 28.11.2025.
//
import SwiftUI
import CoreData


@main
struct AttendanceTrackerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(\.managedObjectContext,
                              persistenceController.container.viewContext)
        }
    }
}

