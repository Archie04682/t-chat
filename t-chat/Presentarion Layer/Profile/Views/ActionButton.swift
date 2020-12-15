//
//  ActionButton.swift
//  t-chat
//
//  Created by Артур Гнедой on 19.11.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import UIKit

class ActionButton: UIButton, ConfigurableView {
    
    func configure(with model: String, theme: Theme?) {
        setTitle(model, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 19, weight: .semibold)
        translatesAutoresizingMaskIntoConstraints = false
        if let theme = theme {
            backgroundColor = theme.filledButtonColor
        }
        layer.cornerRadius = 14
    }

}
