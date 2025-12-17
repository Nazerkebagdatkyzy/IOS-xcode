import SwiftUI
import CoreData
import Firebase

@main
struct AttendanceTrackerApp: App {
    let persistenceController = PersistenceController.shared
    
    init() {
        FirebaseApp.configure()
    }

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
