//
//  StyledLabel.swift
//  t-chat
//
//  Created by Артур Гнедой on 14.11.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import UIKit

final class StyledLabel: UILabel {
    
    func configure(font: UIFont, theme: Theme?) {
        self.font = font
        textAlignment = .center
        numberOfLines = 0
        textColor = theme?.textColor
        translatesAutoresizingMaskIntoConstraints = false
    }
    
}
