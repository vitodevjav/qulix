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
        let request = NSFetchRequest<GifModelMO>(entityName: GifModelMO.entityName)
        for registeredObject in managedContext.registeredObjects {
            guard managedContext.insertedObjects.contains(registeredObject) else {
                managedContext.delete(registeredObject)
                continue
            }
//            guard let registeredGif = registeredObject as? GifModelMO,
//                let url = registeredGif.originalURL else {
//                    continue
//            }
//            request.predicate = NSPredicate(format: "originalURL == %@", url)
//            guard try! managedContext.count(for: request) == 2 else{
//                managedContext.delete(registeredGif)
//                debugPrint(managedContext.insertedObjects.count)
//                debugPrint(managedContext.registeredObjects.count)
//                debugPrint(managedContext.deletedObjects.count)
//                continue
//            }
//        }
        }
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
        }
        debugPrint(managedContext.insertedObjects.count)
        debugPrint(managedContext.registeredObjects.count)
        debugPrint(managedContext.updatedObjects.count)
        debugPrint(managedContext.deletedObjects.count)
        truncate()
    }

    func truncate() {
        let request = NSFetchRequest<GifModelMO>(entityName: "GifModel")
        do {
            let data = try managedContext.fetch(request)
            guard data.count > 50 else {
                return
            }
            for index in 50 ... data.count-1 {
                managedContext.delete(data[index])
            }
            try managedContext.save()
        } catch {
            NSLog("%s", "Error")
        }
        debugPrint(managedContext.insertedObjects.count)
        debugPrint(managedContext.registeredObjects.count)
        debugPrint(managedContext.updatedObjects.count)
        debugPrint(managedContext.deletedObjects.count)
    }
}
