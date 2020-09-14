//
//  ViewController.swift
//  t-chat
//
//  Created by Артур Гнедой on 11.09.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import UIKit

class ViewController: UIViewController, StateLoggable {
    
    var currentState: ViewControllerState = .noState

    override func viewDidLoad() {
        super.viewDidLoad()
        self.changeState(to: .disapeared, in: #function)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.changeState(to: .willLayoutSubviews, in: #function)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.changeState(to: .didLayoutSubviews, in: #function)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.changeState(to: .appearing, in: #function)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.changeState(to: .appeared, in: #function)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.changeState(to: .disapearing, in: #function)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.changeState(to: .disapeared, in: #function)
    }
}

