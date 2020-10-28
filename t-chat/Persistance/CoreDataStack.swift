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
    
    func save(_ block: @escaping (NSManagedObjectContext) -> Void)
    
    func enableObservers()
    
    func printStatictics()
}
