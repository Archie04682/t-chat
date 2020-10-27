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
    var managedContext: NSManagedObjectContext { get }
    
//    func saveContext()
}
