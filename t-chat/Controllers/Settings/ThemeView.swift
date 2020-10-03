//
//  ThemeView.swift
//  t-chat
//
//  Created by Артур Гнедой on 03.10.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import UIKit

class ThemeView: UIView {
    
    private lazy var selectionButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.layer.cornerRadius = 14
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(red: 0x97 / 0xFF, green: 0x97 / 0xFF, blue: 0x97 / 0xFF, alpha: 1.0).cgColor
        
        return button
    }()
    
    private lazy var dialogSampleView: UIStackView = {
        let view = UIStackView(frame: CGRect(x: 0, y: 0, width: self.selectionButton.frame.width, height: 100))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alignment = .fill
        view.distribution = .fill
        view.axis = .vertical
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private lazy var themeNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 19, weight: .semibold)
        
        return label
    }()
    
    private lazy var incommingMessageView: MessageView = {
        let view = MessageView(frame: CGRect.init(x: 0, y: 0, width: self.frame.width, height: self.frame.width))
        view.translatesAutoresizingMaskIntoConstraints = false
    
        return view
    }()
    
    private lazy var outcommingMessageView: MessageView = {
        let view = MessageView(frame: CGRect.init(x: 0, y: 0, width: self.frame.width, height: self.frame.width))
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
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
        incommingMessageView.configure(with: MessageCellModel(text: "Hello, how are u?", isIncomming: true))
        outcommingMessageView.configure(with: MessageCellModel(text: "Hello there! Fine!", isIncomming: false))
        
        dialogSampleView.addArrangedSubview(incommingMessageView)
        dialogSampleView.addArrangedSubview(outcommingMessageView)
        
        selectionButton.addSubview(dialogSampleView)

        dialogSampleView.topAnchor.constraint(equalTo: selectionButton.topAnchor, constant: 5).isActive = true
        dialogSampleView.bottomAnchor.constraint(equalTo: selectionButton.bottomAnchor, constant: -5).isActive = true
        dialogSampleView.leadingAnchor.constraint(equalTo: selectionButton.leadingAnchor).isActive = true
        dialogSampleView.trailingAnchor.constraint(equalTo: selectionButton.trailingAnchor).isActive = true
        
        self.addSubview(selectionButton)
        self.addSubview(themeNameLabel)
        
        selectionButton.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        selectionButton.bottomAnchor.constraint(equalTo: themeNameLabel.topAnchor, constant: -10).isActive = true
        selectionButton.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        selectionButton.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        themeNameLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        themeNameLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
    }
}

extension ThemeView: ConfigurableView {
    func configure(with model: Theme) {
        themeNameLabel.text = model.themeName
        incommingMessageView.setBackgroundColor(model.incomingMessageBackgroundColor)
        incommingMessageView.setMessageColor(model.textColor)
        selectionButton.backgroundColor = model.backgroundColor
        
        outcommingMessageView.setBackgroundColor(model.outcommingMessageBackgroundColor)
        outcommingMessageView.setMessageColor(model.textColor)
        selectionButton.backgroundColor = model.backgroundColor
    }
}
