//
//  CloseModalButton.swift
//  t-chat
//
//  Created by Артур Гнедой on 19.11.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import UIKit

class CloseModalButton: UIBarButtonItem {
    private var clicked: (() -> Void)?
    
    convenience init(onClick action: (() -> Void)?) {
        let barButton = UIButton(frame: CGRect(x: 0, y: 0, width: 34, height: 34))
        let barButtonImage = UIImage(named: "wrong")?.withRenderingMode(.alwaysTemplate)
        barButton.setImage(barButtonImage, for: .normal)
        barButton.tintColor = UIColor.blue
        
        self.init(customView: UILabel())
        
        barButton.addTarget(self, action: #selector(close), for: .touchUpInside)
    }
    
    private override init() {
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func close() {
        clicked?()
    }
}
