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

    static let instance = CoreDataStack()
    private lazy var managedContext: NSManagedObjectContext = {
        return self.storeContainer.viewContext
    }()

    private let modelName = "GifSearcherDataModel"

    private init() {

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

    func createGifModelMO(height: Int, width: Int, rating: String, originalUrl: String, isTrended: Bool) -> GifModelMO {
        let entity = NSEntityDescription.entity(forEntityName: "GifModel", in: managedContext)!
        let gifModel = NSManagedObject(entity: entity,insertInto: managedContext) as! GifModelMO
        gifModel.height = Int32(height)
        gifModel.width = Int32(width)
        gifModel.originalURL = originalUrl
        gifModel.rating = rating
        gifModel.isTrended = isTrended
        return gifModel
    }

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

    func save(data: [GifModelMO]) {
        for model in data {
            let request = NSFetchRequest<GifModelMO>(entityName: "GifModel")
            let res = try? managedContext.fetch(request)
            request.predicate = NSPredicate(format: "originalURL == %@", model.originalURL!)
            let count = try! managedContext.count(for: request)
            guard count == 0 else {
                continue
            }
            managedContext.insert(model)
        }
        do {
            try managedContext.save()
        } catch {
            NSLog("%s", "Error when loading")
        }
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
            NSLog("%s", "Error when fetching")
        }
    }
}
