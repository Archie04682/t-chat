//
//  NavigationViewController.swift
//  t-chat
//
//  Created by Артур Гнедой on 19.11.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import UIKit

class NavigationViewController: UIViewController {
    var navigate: ((UIViewController?, RootDestination, Bool) -> Void)?
}
