//
//  Theme.swift
//  t-chat
//
//  Created by Артур Гнедой on 03.10.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import UIKit

enum Theme: Int, CaseIterable {
    case classic, day, night
    
    var themeName: String {
        switch self {
        case .classic: return "Classic"
        case .day: return "Day"
        case .night: return "Night"
        }
    }
    
    var statusBarStyle: UIBarStyle {
        switch self {
        case .classic, .day: return .default
        case .night: return .black
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
        case .night: return UIColor(red: 0x1E / 0xFF, green: 0x1E / 0xFF, blue: 0x1E / 0xFF, alpha: 1.0)
        }
    }
    
    var barTintColor: UIColor {
        switch self {
        case .classic, .day: return .white
        case .night: return .black
        }
    }
    
    var navigationBarTitleTextAttributes: [NSAttributedString.Key: Any] {
        switch self {
        case .classic, .day: return [NSAttributedString.Key.foregroundColor: UIColor.black]
        case .night: return [NSAttributedString.Key.foregroundColor: UIColor.white]
        }
    }
    
    var conversationBackgroundColor: UIColor {
        switch self {
        case .classic: return UIColor(red: 0xD6 / 0xFF, green: 0xE2 / 0xFF, blue: 0xEE / 0xFF, alpha: 1.0)
        case .day: return .white
        case .night: return .black
        }
    }
    
    var incommingMessageBackgroundColor: UIColor {
        switch self {
        case .classic: return .white
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
    
    var incommingMessageTextColor: UIColor {
        switch self {
        case .classic, .day: return .black
        case .night: return .white
        }
    }
    
    var outcommingMessageTextColor: UIColor {
        switch self {
        case .classic: return .black
        case .night, .day: return .white
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
    
    var onlineCellColor: UIColor {
        switch self {
        case .classic, .day: return UIColor(red: 0.98, green: 0.99, blue: 0.67, alpha: 1.00)
        case .night: return UIColor(red: 0xA1 / 0xFF, green: 0x74 / 0xFF, blue: 0x2B / 0xFF, alpha: 0.3)
        }
    }
    
    var filledButtonColor: UIColor {
        switch self {
        case .classic, .day: return UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.00)
        case .night: return navigationBarColor
        }
    }
    
    var inputFieldBorderBackgroundColor: UIColor {
        switch self {
        case .classic, .day: return UIColor(red: 204.0 / 255.0, green: 204.0 / 255.0, blue: 204.0 / 255.0, alpha: 1.0)
        case .night: return .gray
        }
    }
    
    var inputFieldBackgroundColor: UIColor {
        switch self {
        case .classic, .day: return .white
        case .night: return UIColor.black
        }
    }
    
    var tableViewSeparatorColor: UIColor {
        switch self {
        case .classic, .day: return .gray
        case .night: return UIColor(red: 224 / 255, green: 224 / 255, blue: 224 / 255, alpha: 1)
        }
    }
}
