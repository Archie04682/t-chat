//
//  TCAlertController.swift
//  t-chat
//
//  Created by Артур Гнедой on 22.09.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import UIKit

/*
 
 При вызове UIAlertController в консоль вылазит ошибка лейаута.
 Как написано на SO это давний баг https://stackoverflow.com/questions/55372093/uialertcontrollers-actionsheet-gives-constraint-error-on-ios-12-2-12-3
 Такой workaround помогает не словить эту ошибку
 
 */
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
