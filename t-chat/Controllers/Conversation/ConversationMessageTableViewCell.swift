//
//  ConversationMessageTableViewCell.swift
//  t-chat
//
//  Created by Артур Гнедой on 27.09.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import UIKit

class ConversationMessageTableViewCell: UITableViewCell {
    
    private lazy var container: UIView = {
        var view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private var trailingConstraint: NSLayoutConstraint?
    private var leadingConstraint: NSLayoutConstraint?
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.text = "message"
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        
        container.addSubview(messageLabel)
        contentView.addSubview(container)

        container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10.0).isActive = true
        container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10.0).isActive = true
        
        messageLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 8.0).isActive = true
        messageLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8.0).isActive = true
        messageLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8.0).isActive = true
        messageLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8.0).isActive = true
        
        container.layer.cornerRadius = 16
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension ConversationMessageTableViewCell: ConfigurableView {
    
    typealias ConfigurationModel = MessageCellModel
    
    func configure(with model: MessageCellModel) {
        let largePadding = UIScreen.main.bounds.width * 0.25
        
        container.backgroundColor = model.isIncomming ? UIColor(red: 0.87, green: 0.87, blue: 0.87, alpha: 1.00) : UIColor(red: 0.86, green: 0.97, blue: 0.77, alpha: 1.00)
        
        if let trailing = trailingConstraint {
            trailing.isActive = false
            trailing.constant = model.isIncomming ? -largePadding : -16.0
            trailing.isActive = true
        } else {
            trailingConstraint = container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: model.isIncomming ? -largePadding : -16.0)
            trailingConstraint?.isActive = true
        }
        
        if let leading = leadingConstraint {
            leading.isActive = false
            leading.constant = model.isIncomming ? 16.0 : largePadding
            leading.isActive = true
        } else {
            leadingConstraint = container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: model.isIncomming ? 16.0 : largePadding)
            leadingConstraint?.isActive = true
        }
        
        container.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, model.isIncomming ? .layerMaxXMaxYCorner : .layerMinXMaxYCorner]
        messageLabel.text = model.text
    }
    
}
