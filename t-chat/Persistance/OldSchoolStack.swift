//
//  OldSchoolStack.swift
//  t-chat
//
//  Created by Артур Гнедой on 23.10.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import CoreData
import Foundation

class OldSchoolStack: CoreDataStack {
    private let modelName: String
    
    init(withModel modelName: String) {
        self.modelName = modelName
    }
    
    private lazy var objectModel: NSManagedObjectModel = {
        guard let modelURL = Bundle.main.url(forResource: self.modelName, withExtension: "momd") else {
            fatalError("File not found: \(self.modelName).momd")
        }
        
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Failed to create model")
        }
        
        return model
    }()
    
    private lazy var storeCoordinator: NSPersistentStoreCoordinator = {
        guard let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last else {
            fatalError()
        }
        
        let storeURL = documents.appendingPathComponent("t-chat.sqlite")
        
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.objectModel)
        
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
        } catch {
            fatalError(error.localizedDescription)
        }
        
        return coordinator
    }()
    
    private(set) lazy var managedContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = self.storeCoordinator
        context.mergePolicy = NSOverwriteMergePolicy
        context.parent = self.writerContext
        return context
    }()
    
    private lazy var writerContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = self.storeCoordinator
        context.mergePolicy = NSOverwriteMergePolicy
        
        return context
    }()
    
    private func saveContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = self.managedContext
        context.automaticallyMergesChangesFromParent = true
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return context
    }
    
    func save(_ block: (NSManagedObjectContext) -> Void) {
        let context = saveContext()
        context.performAndWait {
            block(context)
            if context.hasChanges {
                do {
                    try doSave(in: context)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    private func doSave(in context: NSManagedObjectContext) throws {
        try context.save()
        if let parent = context.parent { try doSave(in: parent) }
    }
}
