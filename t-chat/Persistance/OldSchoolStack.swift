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
    
    var didUpdateDatabase: ((CoreDataStack) -> Void)?
    
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
    
    private(set) lazy var mainContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.parent = writerContext
        context.automaticallyMergesChangesFromParent = true
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return context
    }()
    
    private lazy var writerContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = storeCoordinator
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return context
    }()
    
    private func saveContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = mainContext
        context.automaticallyMergesChangesFromParent = true
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return context
    }
    
    func save(_ block: @escaping (NSManagedObjectContext) -> Void) {
        let context = saveContext()
        context.perform {
            block(context)
            if context.hasChanges {
                self.doSave(in: context)
            }
        }
    }
    
    private func doSave(in context: NSManagedObjectContext) {
        context.perform {
            do {
                try context.save()
                if let parent = context.parent {
                    self.doSave(in: parent)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func enableObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(contextObjectsDidChange(notification:)),
                                               name: NSNotification.Name.NSManagedObjectContextObjectsDidChange,
                                               object: mainContext)
    }
    
    @objc private func contextObjectsDidChange(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        
        didUpdateDatabase?(self)
        
        [NSInsertedObjectsKey: "Added", NSUpdatedObjectsKey: "Updated", NSDeletedObjectsKey: "Deleted"].forEach { key, description in
            if let objects = userInfo[key] as? Set<NSManagedObject>, !objects.isEmpty {
                print("⚠️ \(description): \(objects.count) objects" )
            }
        }
    }
    
    func printStatictics() {
        mainContext.perform {
            do {
                let channelCount = try self.mainContext.count(for: ChannelEntity.fetchRequest())
                print("📗 \(channelCount) channels")
                let messagesCount = try self.mainContext.count(for: MessageEntity.fetchRequest())
                print("📗 \(messagesCount) messages")
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
}
