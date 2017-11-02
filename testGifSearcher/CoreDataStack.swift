//
//  CoreDataStack.swift
//  testGifSearcher
//
//  Created by Kazakevich, Vitaly on 10/31/17.
//  Copyright © 2017 Vitalik. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {

    lazy var managedContext: NSManagedObjectContext = {
        return self.storeContainer.viewContext
    }()

    private let modelName: String

    init(modelName: String) {
        self.modelName = modelName
    }
    private lazy var storeContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: self.modelName)
        container.loadPersistentStores {
            (storeDescription, error) in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    func saveContext () {
        debugPrint(managedContext.insertedObjects.count)
        debugPrint(managedContext.registeredObjects.count)
        debugPrint(managedContext.updatedObjects.count)
        debugPrint(managedContext.deletedObjects.count)
        guard managedContext.hasChanges else {
            return
        }
        let inserted = Array(managedContext.insertedObjects)
        if inserted.count > 50 {
            for index in 50 ... inserted.count-1 {
                managedContext.delete(inserted[index])
            }
        }
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
        }
    }
}
