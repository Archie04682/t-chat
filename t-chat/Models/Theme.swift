//
//  Theme.swift
//  t-chat
//
//  Created by Артур Гнедой on 03.10.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import UIKit

enum Theme {
    case classic, day, night
    
    var themeName: String {
        switch self {
        case .classic: return "Classic"
        case .day: return "Day"
        case .night: return "Night"
        }
    }
    
    var backgroundColor: UIColor {
        switch self {
        case .classic, .day: return .white
        case .night: return .black
        }
    }
    
    var navigationBarColor: UIColor {
        switch self {
        case .classic, .day: return .white
        case .night: return .black
        }
    }
    
    var incomingMessageBackgroundColor: UIColor {
        switch self {
        case .classic: return UIColor(red: 0xDF / 0xFF, green: 0xDF / 0xFF, blue: 0xDF / 0xFF, alpha: 1.0)
        case .day: return UIColor(red: 0xEA / 0xFF, green: 0xEB / 0xFF, blue: 0xED / 0xFF, alpha: 1.0)
        case .night: return UIColor(red: 0x2E / 0xFF, green: 0x2E / 0xFF, blue: 0x2E / 0xFF, alpha: 1.0)
        }
    }
    
    var outcommingMessageBackgroundColor: UIColor {
        switch self {
            case .classic: return UIColor(red: 0xDC / 0xFF, green: 0xF7 / 0xFF, blue: 0xC5 / 0xFF, alpha: 1.0)
            case .day: return UIColor(red: 0x43 / 0xFF, green: 0x89 / 0xFF, blue: 0xF9 / 0xFF, alpha: 1.0)
            case .night: return UIColor(red: 0x5C / 0xFF, green: 0x5C / 0xFF, blue: 0x5C / 0xFF, alpha: 1.0)
        }
    }
    
    var textColor: UIColor {
        switch self {
        case .classic, .day: return .black
        case .night: return .white
        }
    }
    
    var subtitleColor: UIColor {
        switch self {
        case .classic, .day: return UIColor(red: 0x3C / 0xFF, green: 0x3C / 0xFF, blue: 0x43 / 0xFF, alpha: 1.0)
        case .night: return UIColor(red: 0x8D / 0xFF, green: 0x8D / 0xFF, blue: 0x93 / 0xFF, alpha: 1.0)
        }
    }
}
