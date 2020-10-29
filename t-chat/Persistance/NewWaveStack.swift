//
//  NewWaveStack.swift
//  t-chat
//
//  Created by Артур Гнедой on 29.10.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import CoreData
import Foundation

final class NewWaveStack: CoreDataStack {
    
    private let databaseName: String
    
    init(withModel databaseName: String) {
        self.databaseName = databaseName
    }
    
    var didUpdateDatabase: ((CoreDataStack) -> Void)?
    
    private lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: self.databaseName)
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                fatalError(error.localizedDescription)
            }
            
            guard let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last else {
                fatalError()
            }
            
            let storeURL = documents.appendingPathComponent("t-chat.sqlite")
            
            storeDescription.type = NSSQLiteStoreType
            storeDescription.url = storeURL
        }
        
        return container
    }()
    
    private(set) lazy var mainContext: NSManagedObjectContext = {
        let context = container.viewContext
        
        context.automaticallyMergesChangesFromParent = true
        context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        
        return context
    }()
    
    func save(_ block: @escaping (NSManagedObjectContext) -> Void) {
        container.performBackgroundTask { context in
            block(context)
            guard context.hasChanges else { return }
            do {
                try context.save()
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
            if let objects = userInfo[key] as? Set<NSManagedObject>, objects.count > 0 {
                print("⚠️ \(description): \(objects.count) objects" )
            }
        }
    }
    
}
