import Foundation
import CoreData

struct ImportSchoolsService {

    static func forceImport(context: NSManagedObjectContext) {

        deleteAllSchools(context: context)
        importSchools(context: context)
    }

    private static func deleteAllSchools(context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = School.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(deleteRequest)
            try context.save()
            print("🔥 ALL OLD SCHOOLS DELETED")
        } catch {
            print("❌ Delete error:", error)
        }
    }

    private static func importSchools(context: NSManagedObjectContext) {

        guard let url = Bundle.main.url(forResource: "schools", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("❌ schools.json табылмады")
            return
        }

        struct RegionModel: Codable {
            let name: String
            let schools: [SchoolModel]
        }

        struct CityModel: Codable {
            let city: String
            let regions: [RegionModel]
        }

        struct SchoolModel: Codable {
            let id: String
            let name: String
        }

        guard let cities = try? JSONDecoder().decode([CityModel].self, from: data) else {
            print("❌ Decode error")
            return
        }

        for city in cities {
            for region in city.regions {
                for school in region.schools {

                    let s = School(context: context)
                    s.id = school.id
                    s.name = school.name
                    s.city = city.city
                    s.region = region.name
                }
            }
        }

        try? context.save()
        print("✅ ALL SCHOOLS IMPORTED SUCCESSFULLY")
    }
}

