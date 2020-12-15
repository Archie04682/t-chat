//
//  StateLoggingViewController.swift
//  t-chat
//
//  Created by Артур Гнедой on 22.09.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import UIKit

class StateLoggingViewController: UIViewController, StateLoggable {
    var currentState: ViewControllerState = .noState
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.logTransition(nextState: .disapeared, in: #function)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.logTransition(nextState: .willLayoutSubviews, in: #function)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.logTransition(nextState: .didLayoutSubviews, in: #function)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.logTransition(nextState: .appearing, in: #function)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.logTransition(nextState: .appeared, in: #function)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.logTransition(nextState: .disapearing, in: #function)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.logTransition(nextState: .disapeared, in: #function)
    }
}
