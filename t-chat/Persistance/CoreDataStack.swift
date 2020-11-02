//
//  CoreDataStack.swift
//  t-chat
//
//  Created by Артур Гнедой on 23.10.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import CoreData
import Foundation

protocol CoreDataStack {
    var didUpdateDatabase: ((CoreDataStack) -> Void)? { get set }
    
    var mainContext: NSManagedObjectContext { get }
    
    func save(_ block: @escaping (NSManagedObjectContext) -> Void, completion: @escaping (Error?) -> Void)
    
    func enableObservers()
    
    func printStatictics()
}

extension CoreDataStack {
    
    func printStatictics() {
        mainContext.perform {
            do {
                let channelCount = try self.mainContext.count(for: ChannelEntity.fetchRequest())
                print("☎️ \(channelCount) channels")
                let messagesCount = try self.mainContext.count(for: MessageEntity.fetchRequest())
                print("✉️ \(messagesCount) messages")
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    func getIconForEvent(eventName: String) -> String {
        switch eventName {
        case NSInsertedObjectsKey: return "✅"
        case NSDeletedObjectsKey: return "🔻"
        case NSUpdatedObjectsKey: return "🔸"
        default:
            return "🛑"
        }
    }
    
}
