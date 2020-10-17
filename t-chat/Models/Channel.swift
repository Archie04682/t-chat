//
//  Channel.swift
//  t-chat
//
//  Created by Артур Гнедой on 17.10.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import Foundation

struct Channel {
    let identifier: String
    let name: String
    let lastMessage: String?
    let lastActivity: Date?
}
