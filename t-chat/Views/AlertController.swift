//
//  TCAlertController.swift
//  t-chat
//
//  Created by Артур Гнедой on 22.09.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import UIKit

class AlertController: UIAlertController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        for subView in self.view.subviews {
            for constraint in subView.constraints where constraint.debugDescription.contains("width == - 16") {
                subView.removeConstraint(constraint)
            }
        }
    }

}
