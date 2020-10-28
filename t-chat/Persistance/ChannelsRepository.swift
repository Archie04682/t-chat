//
//  ChannelsRepository.swift
//  t-chat
//
//  Created by Артур Гнедой on 27.10.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import CoreData
import Foundation

class ChannelRepository {
    private let coreDataStack: CoreDataStack
    
    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }
    
    func addMessages(messages: [Message], to channel: Channel) {
        coreDataStack.save { context in
            let fetchRequest: NSFetchRequest<ChannelEntity> = ChannelEntity.fetchRequest()
            fetchRequest.fetchLimit = 1
            fetchRequest.entity = NSEntityDescription.entity(forEntityName: "ChannelEntity", in: context)
            fetchRequest.predicate = NSPredicate(format: "uid = \"\(channel.identifier)\"")
            
            do {
                if let channel = (try context.fetch(fetchRequest) as [ChannelEntity]).first {
                    messages.compactMap { MessageEntity(with: $0, in: context) }.forEach { channel.addToMessages($0) }
                }
                
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
