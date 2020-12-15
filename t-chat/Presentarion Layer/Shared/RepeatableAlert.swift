//
//  RepeatableAlert.swift
//  t-chat
//
//  Created by Артур Гнедой on 14.11.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import UIKit

class RepeatableAlert: UIAlertController {

    var repeatHandler: (() -> Void)?
    var okHandler: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
            self.dismiss(animated: true) {
                self.okHandler?()
            }
        }))
        addAction(UIAlertAction(title: "Repeat", style: .default, handler: { _ in
            self.dismiss(animated: true) {
                self.repeatHandler?()
            }
        }))
    }

}
