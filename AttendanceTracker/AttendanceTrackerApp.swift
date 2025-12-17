import SwiftUI
import CoreData
import Firebase

@main
struct AttendanceTrackerApp: App {

    let persistenceController = PersistenceController.shared

    init() {
        FirebaseApp.configure()   // ✅ МІНДЕТТІ
    }

    var body: some Scene {
        WindowGroup {
            StartView()
                .environment(\.managedObjectContext,
                              persistenceController.container.viewContext)
                .onAppear {
                    seedSchoolsIfNeeded(
                        context: persistenceController.container.viewContext
                    )
                }
        }
    }

    // MARK: - Seed initial schools
    private func seedSchoolsIfNeeded(context: NSManagedObjectContext) {

        let req: NSFetchRequest<School> = School.fetchRequest()
        let count = (try? context.count(for: req)) ?? 0

        if count > 0 {
            print("ℹ️ Schools already exist")
            return
        }

        let schoolsData = [
            ("1", "School №1", "Almaty", "Bostandyk"),
            ("2", "School №2", "Almaty", "Auezov"),
            ("3", "School №5", "Astana", "Yesil")
        ]

        for (id, name, city, region) in schoolsData {
            let s = School(context: context)
            s.id = id
            s.name = name
            s.city = city
            s.region = region
        }

        do {
            try context.save()
            print("✅ Schools seeded successfully")
        } catch {
            print("❌ Failed to seed schools:", error)
        }
    }
}
