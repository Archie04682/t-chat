//
//  SelectionButton.swift
//  t-chat
//
//  Created by Артур Гнедой on 04.10.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import UIKit

class ThemeSelectionButton: UIButton {

    override var isSelected: Bool {
        didSet {
            if isSelected {
                layer.borderWidth = 3
                layer.borderColor = UIColor(red: 0x00 / 0xFF, green: 0x7A / 0xFF, blue: 0xFF / 0xFF, alpha: 1.0).cgColor
            } else {
                layer.borderWidth = 1
                layer.borderColor = UIColor(red: 0x97 / 0xFF, green: 0x97 / 0xFF, blue: 0x97 / 0xFF, alpha: 1.0).cgColor
            }
        }
    }

}
