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
        container.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError(error.localizedDescription)
            }
        }
        
        return container
    }()
    
    private(set) lazy var mainContext: NSManagedObjectContext = {
        let context = container.viewContext
        context.automaticallyMergesChangesFromParent = true
        
        return context
    }()
    
    func save(_ block: @escaping (NSManagedObjectContext) -> Void, completion: @escaping (Error?) -> Void) {
        container.performBackgroundTask { context in
            context.mergePolicy = NSOverwriteMergePolicy
            
            block(context)
            guard context.hasChanges else { return }
            do {
                try context.save()
            } catch {
                completion(error)
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
                print("\(getIconForEvent(eventName: key)) \(description): \(objects.count) objects" )
            }
        }
    }
    
}
