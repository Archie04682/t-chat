//
//  DataObject.swift
//  t-chat
//
//  Created by Артур Гнедой on 12.11.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import Foundation
import CoreData

struct ObjectChanges<T> {
    var index: Int?
    var object: T
    var newIndex: Int?
    var changeType: ChangeType
}

enum ChangeType {
    case insert, update, delete, move
}

extension ChangeType {
    init(from type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            self = .insert
            return
        case .delete:
            self = .delete
            return
        case .move:
            self = .move
            return
        case .update:
            self = .update
            return
        @unknown default:
            fatalError("Unknown type")
        }
    }
}
