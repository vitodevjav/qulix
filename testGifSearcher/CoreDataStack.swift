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
    lazy var managedContext: NSManagedObjectContext = {
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
}
