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
        self.processState(nextState: .disapeared, in: #function)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.processState(nextState: .willLayoutSubviews, in: #function)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.processState(nextState: .didLayoutSubviews, in: #function)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.processState(nextState: .appearing, in: #function)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.processState(nextState: .appeared, in: #function)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.processState(nextState: .disapearing, in: #function)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.processState(nextState: .disapeared, in: #function)
    }
}

