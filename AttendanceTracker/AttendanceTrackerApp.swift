import SwiftUI
import CoreData

@main
struct AttendanceTrackerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            StartView()
                .environment(\.managedObjectContext,
                              persistenceController.container.viewContext)
                .onAppear {
                    NotificationService.requestPermission()
                }
        }
    }
}
