//
//  MultithreadingDataManager.swift
//  t-chat
//
//  Created by Артур Гнедой on 09.10.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import Foundation

protocol FileManager: AnyObject {
    
    associatedtype DataType
    
    func read(from: String) throws -> DataType?
    func write(_ data: DataType, to: String) throws
    
}
