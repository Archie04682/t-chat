//
//  MessageRepository.swift
//  t-chat
//
//  Created by Артур Гнедой on 13.11.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import CoreData
import Foundation

protocol MessageRepositoryDelegate: AnyObject {
    func messagesUpdated(_ data: Result<[ObjectChanges<Message>], Error>)
}

protocol MessageRepository {
    var delegate: MessageRepositoryDelegate? { get set }
    
    func fetch(forChannelWithUID uid: String)
    
    func add(_ messages: [Message], forChannelWithUID uid: String, completion: @escaping (Error?) -> Void)
}

final class CoreDataMessageRepository: NSObject, MessageRepository {
    
    private let coreDataStack: CoreDataStack
    private var frc: NSFetchedResultsController<MessageEntity>?
    private var updated: [ObjectChanges<Message>] = []
    var delegate: MessageRepositoryDelegate?
    
    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }
    
    func fetch(forChannelWithUID uid: String) {
        initFetchResultsController(forChannel: uid, sortBy: #keyPath(MessageEntity.created),
        ascending: false)
        
        do {
            try frc?.performFetch()
            
            if let enumerated = frc?.fetchedObjects?.enumerated() {
                for (index, ent) in enumerated {
                    let channel = Message(from: ent)
                    updated.append(ObjectChanges<Message>(index: nil, object: channel, newIndex: index, changeType: .insert))
                }
            }
            
            if !updated.isEmpty {
                delegate?.messagesUpdated(.success(updated))
            }
            
        } catch {
            delegate?.messagesUpdated(.failure(error))
        }
        
    }
    
    func add(_ messages: [Message], forChannelWithUID uid: String, completion: @escaping (Error?) -> Void) {
        coreDataStack.save({ context in
            if let existingChannel = self.getChannelBy(uid: uid) {
                for message in messages {
                    if let uid = message.uid {
                        let fetchRequest: NSFetchRequest<MessageEntity> = MessageEntity.fetchRequest()
                        fetchRequest.predicate = NSPredicate(format: "uid == %@", uid)
                        if let count = try? context.count(for: fetchRequest), count == 0, let entity = MessageEntity(with: message, in: context) {
                            existingChannel.addToMessages(entity)
                        }
                    }
                }
            }
        }, completion: { error in
            completion(error)
        })
    }
    
    private func getChannelBy(uid: String) -> ChannelEntity? {
        let fetchRequest: NSFetchRequest<ChannelEntity> = ChannelEntity.fetchRequest()
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "uid == %@", uid)
        
        if let existing = try? coreDataStack.mainContext.fetch(fetchRequest).first {
            return existing
        }
        
        return nil
    }
    
    private func initFetchResultsController(forChannel channelId: String,
                                            sortBy sortField: String,
                                            ascending: Bool,
                                            fetchBatchSize: Int = 20,
                                            withCache: Bool = false) {
        
        if let existing = getChannelBy(uid: channelId) {
            let request: NSFetchRequest<MessageEntity> = MessageEntity.fetchRequest()
            request.predicate = NSPredicate(format: "%K == %@", #keyPath(MessageEntity.channel), existing.objectID)
            request.sortDescriptors = [NSSortDescriptor(key: sortField, ascending: ascending)]
            request.fetchBatchSize = fetchBatchSize
            frc = NSFetchedResultsController(fetchRequest: request,
                                                        managedObjectContext: coreDataStack.mainContext,
                                                        sectionNameKeyPath: nil,
                                                        cacheName: withCache ? "MessagesCache" : nil)
        }
    }
}

extension CoreDataMessageRepository: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updated.removeAll()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        if let object = anObject as? MessageEntity {
            updated.append(ObjectChanges<Message>(index: indexPath?.row, object: Message(from: object), newIndex: newIndexPath?.row, changeType: ChangeType(from: type)))
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if !updated.isEmpty {
            delegate?.messagesUpdated(.success(updated))
        }
    }
}
