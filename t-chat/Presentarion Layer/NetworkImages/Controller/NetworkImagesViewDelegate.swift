//
//  NetworkImagesViewDelegate.swift
//  t-chat
//
//  Created by Артур Гнедой on 18.11.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import Foundation
import UIKit

protocol NetworkImagesViewDelegate: AnyObject {
    func didSelect(image: UIImage)
}
