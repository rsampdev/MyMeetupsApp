//
//  CoreDataStack.swift
//  MyMeetups
//
//  Created by Rodney Sampson on 9/28/16.
//  Copyright © 2016 Rodney Sampson II. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    private var modelName: String
    private var managedObjectModel: NSManagedObjectModel
    private var persistentStoreCoordinator: NSPersistentStoreCoordinator
    var mainQueueContext: NSManagedObjectContext
    var privateQueueContext: NSManagedObjectContext
    
    init(modelName: String) {
        self.modelName = modelName
        guard let modelURL = Bundle.main.url(forResource: self.modelName, withExtension: "momd") else {
            fatalError("Model URL Shoud never be nil.")
        }
        self.managedObjectModel = NSManagedObjectModel(contentsOf: modelURL)!
        let psc = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel) as  NSPersistentStoreCoordinator?
        let pathExtention = ".sqlite"
        let fileName = "\(self.modelName)\(pathExtention)"
        let storeURL = CoreDataStack.appDocumentsDirectory().appendingPathComponent(fileName)
        var store: NSObject?
        do {
            try store = (psc?.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil))!
        } catch let error {
            print(error)
        }
        assert(store != nil, "Fatal: couldn't instantiate the store. Bailing.");
        self.persistentStoreCoordinator = psc!
        let mqc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        mqc.persistentStoreCoordinator = self.persistentStoreCoordinator
        mqc.name = "Main Queue Context (UI Context)"
        self.mainQueueContext = mqc
        let pqc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        pqc.parent = self.mainQueueContext
        pqc.name = "Private Queue Context (UI Context)"
        self.privateQueueContext = pqc
    }
    
    convenience init() {
        self.init(modelName: "MyMeetups")
    }
    
    private static func appDocumentsDirectory() -> URL{
        let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        return docsURL!
    }
    
    @discardableResult
    func saveChanges(error: Error?) -> Bool {
        var success = false;
        self.privateQueueContext.performAndWait {
            if self.privateQueueContext.hasChanges {
                try! self.privateQueueContext.save()
            }
            success = true
        }
        if success == false {
            return false
        }
        self.mainQueueContext.performAndWait {
            if self.mainQueueContext.hasChanges {
                try! self.mainQueueContext.save()
            }
            success = true
        }
        
        return success;
    }
    
}
