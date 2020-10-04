//
//  MessageView.swift
//  t-chat
//
//  Created by Артур Гнедой on 03.10.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import UIKit

class MessageView: UIView {
    
    private var trailingConstraint: NSLayoutConstraint?
    private var leadingConstraint: NSLayoutConstraint?
    
    private lazy var container: UIView = {
        var view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.text = "message"
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    override init (frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    private func setupView() {
        container.addSubview(messageLabel)
        self.addSubview(container)

        container.topAnchor.constraint(equalTo: self.topAnchor, constant: 4.0).isActive = true
        container.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -4.0).isActive = true
        
        messageLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 8.0).isActive = true
        messageLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8.0).isActive = true
        messageLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8.0).isActive = true
        messageLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8.0).isActive = true
        
        container.layer.cornerRadius = 16
    }
    
    func setBackgroundColor(_ color: UIColor) {
        container.backgroundColor = color
    }
    
    func setMessageColor(_ color: UIColor) {
        messageLabel.textColor = color
    }

}

extension MessageView: ConfigurableView {
    
    typealias ConfigurationModel = MessageCellModel
    
    func configure(with model: MessageCellModel) {
        let largePadding = UIScreen.main.bounds.width * 0.25
        
        container.backgroundColor = model.isIncomming ? UIColor(red: 0.87, green: 0.87, blue: 0.87, alpha: 1.00) : UIColor(red: 0.86, green: 0.97, blue: 0.77, alpha: 1.00)
        
        trailingConstraint?.isActive = false
        trailingConstraint = model.isIncomming ? container.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor, constant: -largePadding) : container.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10)
        trailingConstraint?.isActive = true

        leadingConstraint?.isActive = false
        leadingConstraint = model.isIncomming ? container.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10) : container.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor, constant: largePadding)
        leadingConstraint?.isActive = true
        
        container.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, model.isIncomming ? .layerMaxXMaxYCorner : .layerMinXMaxYCorner]
        messageLabel.text = model.text
    }
    
}
