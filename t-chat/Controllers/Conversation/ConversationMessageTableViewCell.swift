//
//  ConversationMessageTableViewCell.swift
//  t-chat
//
//  Created by Артур Гнедой on 27.09.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import UIKit

class ConversationMessageTableViewCell: UITableViewCell {
    
    private lazy var messageView: MessageView  = {
        let view = MessageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        
        contentView.addSubview(messageView)

        messageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5.0).isActive = true
        messageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5.0).isActive = true
        messageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        messageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension ConversationMessageTableViewCell: ConfigurableView {
    
    typealias ConfigurationModel = MessageCellModel
    
    func configure(with model: MessageCellModel) {
        messageView.configure(with: model)
    }
    
}
