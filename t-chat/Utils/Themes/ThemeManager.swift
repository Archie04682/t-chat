//
//  ThemeManager.swift
//  t-chat
//
//  Created by Артур Гнедой on 04.10.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import UIKit

class ThemeManager: NSObject {
    private let dispatchQueue: DispatchQueue
    
    weak var delegate: ThemePickerDelegate?
    var didPickTheme: ((Theme) -> Void)?
    
    private let themeKey = "theme"
    
    static var shared: ThemeManager = {
       return ThemeManager()
    }()
    
    private var theme: Theme
    
    var currentTheme: Theme {
        return theme
    }
    
    private override init() {
        if let storedTheme = (UserDefaults.standard.value(forKey: themeKey) as AnyObject).integerValue {
            theme = Theme(rawValue: storedTheme) ?? .classic
        } else {
            theme = .classic
        }
        
        dispatchQueue = DispatchQueue(label: "ThemeManager", qos: .userInitiated, attributes: [], autoreleaseFrequency: .inherit, target: nil)
    }
    
    func apply(theme: Theme) {
        UINavigationBar.appearance().backgroundColor = theme.navigationBarColor
        UINavigationBar.appearance().barTintColor = theme.barTintColor
        UINavigationBar.appearance().titleTextAttributes = theme.navigationBarTitleTextAttributes
        UINavigationBar.appearance().barStyle = theme.statusBarStyle
        UITableView.appearance().backgroundColor = theme.conversationBackgroundColor
        UILabel.appearance().textColor = theme.textColor
        
        delegate?.didSelectTheme(theme: theme)
        if let closure = didPickTheme {
            closure(theme)
        }
    }
    
    func save(theme: Theme, completion: @escaping () -> Void) {
        if self.theme != theme {
            dispatchQueue.async {[weak self] in
                if let self = self {
                    // iOS 13+ вылазит ошибка описанная тут https://developer.apple.com/forums/thread/121527.
                    // Как я понимаю, это какой то баг платформы.
                    UserDefaults.standard.set(theme.rawValue, forKey: self.themeKey)
                    self.theme = theme
                    completion()
                }
            }
        }
    }
}

extension ThemeManager: NSCopying {
    
    func copy(with zone: NSZone? = nil) -> Any {
        return self
    }
    
}
