import SwiftUI
import CoreData

@main
struct AttendanceTrackerApp: App {

    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            StartView()
                .environment(
                    \.managedObjectContext,
                    persistenceController.container.viewContext
                )
                .onAppear {
                    // 🔔 Notification рұқсаты
                    NotificationService.requestPermission()

                    // 🏫 Мектептерді базаға салу
                    seedSchoolsIfNeeded(
                        context: persistenceController.container.viewContext
                    )
                }
        }
    }
}

func seedSchoolsIfNeeded(context: NSManagedObjectContext) {

    let req: NSFetchRequest<School> = School.fetchRequest()
    let count = (try? context.count(for: req)) ?? 0
    if count > 0 { return } // ❗ Бір рет қана толады

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

    try? context.save()
    print("✅ Schools seeded")
}
