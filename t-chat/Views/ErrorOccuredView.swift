//
//  ErrorOccuredView.swift
//  t-chat
//
//  Created by Артур Гнедой on 02.11.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import UIKit

class ErrorOccuredView: UIAlertController {
    
    convenience init(message: String) {
        self.init(title: "Error occured", message: message, preferredStyle: .alert)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Error occured"
        addAction(UIAlertAction(title: "Ok", style: .cancel))
    }

}
