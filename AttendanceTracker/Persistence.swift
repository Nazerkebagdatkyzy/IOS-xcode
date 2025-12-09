//
//  Persistence.swift
//  AttendanceTracker
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "AttendanceTracker")
        // 👆 МІНДЕТТІ: аты .xcdatamodeld файлыңмен 1:1 сәйкес болуы керек

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

            // 🟦 1. get store description
            let description = container.persistentStoreDescriptions.first
            description?.setOption(true as NSNumber, forKey: NSMigratePersistentStoresAutomaticallyOption)
            description?.setOption(true as NSNumber, forKey: NSInferMappingModelAutomaticallyOption)

            // 🟦 2. Егер inMemory — тест үшін қолданамыз
            if inMemory {
                description?.url = URL(fileURLWithPath: "/dev/null")
            }

            // 🟦 3. Тек ЕГІМА цифр loadPersistentStores
            container.loadPersistentStores { (_, error) in
                if let error = error as NSError? {
                    fatalError("Unresolved Core Data error \(error), \(error.userInfo)")
                }
            }

            container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        }

    }

