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

    func fetch() -> [GifModelMO]? {
        let request = NSFetchRequest<GifModelMO>(entityName: "GifModel")
        do {
            let data = try managedContext.fetch(request)
            return data
        } catch {
            NSLog("%s", "Error when fetching")
            return nil
        }
    }

    func saveContext () {
        guard managedContext.hasChanges else {
            return
        }
        let request = NSFetchRequest<GifModelMO>(entityName: GifModelMO.entityName)
        debugPrint(managedContext.insertedObjects.count)
        debugPrint(managedContext.registeredObjects.count)
        debugPrint(managedContext.updatedObjects)
        debugPrint(managedContext.deletedObjects)
        for insertedObject in managedContext.insertedObjects {
            guard let insertedGif = insertedObject as? GifModelMO,
                let url = insertedGif.originalURL else {
                    continue
            }
            request.predicate = NSPredicate(format: "%K == %@", url)
        }
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
        }
        debugPrint(managedContext.insertedObjects.count)
        debugPrint(managedContext.registeredObjects.count)
        debugPrint(managedContext.updatedObjects)
        debugPrint(managedContext.deletedObjects)
    }

    func truncate() {
        let request = NSFetchRequest<GifModelMO>(entityName: "GifModel")
        do {
            let data = try managedContext.fetch(request)
            guard data.count > 20 else {
                return
            }
            for index in 20 ... data.count-1 {
                managedContext.delete(data[index])
            }
            try managedContext.save()
        } catch {
            NSLog("%s", "Error")
        }
    }
}
