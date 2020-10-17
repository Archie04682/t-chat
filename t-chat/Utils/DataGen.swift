//
//  DataGen.swift
//  t-chat
//
//  Created by Артур Гнедой on 26.09.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import Foundation

// Класс для генерации "случайных" данных.

class DataGen {
    
    private lazy var firstNames = [
        "Oliver", "Harry", "George", "Noah", "Jack", "Jacob", "Leo", "Oscar", "Charlie", "Jamie",
        "Olivia", "Amelia", "Isla", "Ava", "Emily", "Isabella", "Mia", "Poppy", "Ella", "Lily"
    ]
    
    private lazy var lastNames = [
        "Smith", "Murphy", "Jones", "O'Kelly", "Johnson", "Williams", "O'Sullivan", "Brown", "Walsh", "Taylor",
        "Davies", "O'Brien", "Miller", "Wilson", "Byrne", "Davis", "Evans", "O'Ryan", "Garcia", "Thomas"
    ]
    
    private lazy var messages = [
        "",
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
        "Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum",
        "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis " +
        "aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.",
        "Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, " +
        "eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem " +
        "quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. " +
        "Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora " +
        "incidunt ut labore et dolore magnam aliquam quaerat voluptatem."
    ]
    
    func generateConversationsList(count: Int) -> [ConversationCellModel] {
        var models: [ConversationCellModel] = []
        for i in 0..<count {
            var name = generateName()
            
            while !models.filter({ $0.name == name }).isEmpty {
                name = generateName()
            }
            
            let model = ConversationCellModel(name: name,
                                              message: messages[Int.random(in: 0..<messages.count)],
                                              date: i % 3 == 0 ? Date() : generateDate(),
                                              isOnline: i % 2 == 0, hasUnreadMessages: i % 3 != 0)
            models.append(model)
        }
        
        return models
    }
    
    func generateMessages(firstMessage: String) -> [MessageCellModel] {
        var models: [MessageCellModel] = [MessageCellModel(text: firstMessage, isIncomming: true)]
        for _ in 0..<Int.random(in: 3..<10) {
            var message = messages[Int.random(in: 0..<messages.count)]
            
            while message.isEmpty {
                message = messages[Int.random(in: 0..<messages.count)]
            }
            
            models.append(MessageCellModel(text: message, isIncomming: Bool.random()))
        }
        
        return models
    }
    
    private func generateName() -> String {
        return "\(firstNames[Int.random(in: 0..<firstNames.count)]) \(lastNames[Int.random(in: 0..<lastNames.count)])"
    }
    
    private func generateDate() -> Date {
        let interval = Int.random(in: 1000..<86000000)
        return Date(timeIntervalSinceNow: TimeInterval(interval))
    }
}
