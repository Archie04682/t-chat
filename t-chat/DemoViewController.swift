//
//  DemoViewController.swift
//  t-chat
//
//  Created by Артур Гнедой on 11.09.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import UIKit

class DemoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func goBackPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
