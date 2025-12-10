import SwiftUI
import CoreData

@main
struct AttendanceTrackerApp: App {
    let persistence = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            StartView()
                .environment(\.managedObjectContext, persistence.container.viewContext)
                .onAppear {
                    ImportSchoolsService.forceImport(context: persistence.container.viewContext)
                }
        }
    }
}

