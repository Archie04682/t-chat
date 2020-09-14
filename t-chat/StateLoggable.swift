//
//  StateLoggable.swift
//  t-chat
//
//  Created by Артур Гнедой on 11.09.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//
import UIKit

protocol StateLoggable: AnyObject {
    associatedtype ItemState
    var currentState: ItemState { get set }
}

extension StateLoggable {
    func changeState(to nextState: ItemState, in function: String) {
        if ProcessInfo.processInfo.environment["state_logging_level"] == "verbose" {
            print("\(String(describing: type(of: self))) moved from \(currentState) to \(nextState): \(function)")
        }
        
        self.currentState = nextState
    }
}

