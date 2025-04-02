//
//  Persistence.swift
//  DiyanetAPP
//
//  Created by Güçlü Ceyhan on 4/2/25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        // Preview verileri oluşturabiliriz, fakat şu an için buna gerek yok
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "DiyanetAPP")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Bu bir ciddi uygulama hatası olacağından, crash log oluşturmak uygundur.
                // Uygulama kullanıcıya bu durumu bildirmeli ve temiz bir şekilde çıkış yapmalıdır.
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
