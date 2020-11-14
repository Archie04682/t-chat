//
//  Backdrop.swift
//  t-chat
//
//  Created by Артур Гнедой on 09.10.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import UIKit

class Backdrop: UIView {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    override init (frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.15)
    }

}
