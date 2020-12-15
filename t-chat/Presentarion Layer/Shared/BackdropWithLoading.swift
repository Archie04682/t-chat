//
//  Backdrop.swift
//  t-chat
//
//  Created by Артур Гнедой on 09.10.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import UIKit

class BackdropWithLoading: UIView {
    
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
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = .red
        activityIndicator.startAnimating()
        
        addSubview(activityIndicator)
        activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }

}
