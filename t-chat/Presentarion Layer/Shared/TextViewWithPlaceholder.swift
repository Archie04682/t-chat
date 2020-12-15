//
//  TextViewWithPlaceholder.swift
//  t-chat
//
//  Created by Артур Гнедой on 14.11.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import UIKit

class TextViewWithPlaceholder: UITextView {
    
    weak var textDelegate: UITextViewDelegate?
    
    private lazy var aboutTextViewPlaceholder: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.sizeToFit()
        label.textColor = .gray
        
        label.isHidden = true
        return label
    }()
    
    func configure(placeholder: String, theme: Theme, cornerRadius: CGFloat = 4.0) {
        translatesAutoresizingMaskIntoConstraints = false
        font = UIFont.systemFont(ofSize: 16, weight: .regular)
        isScrollEnabled = false
        isHidden = true
        delegate = self
        layer.borderWidth = 1.5
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true
        
        addSubview(aboutTextViewPlaceholder)
        aboutTextViewPlaceholder.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5).isActive = true
        aboutTextViewPlaceholder.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        textColor = theme.textColor
        backgroundColor = theme.inputFieldBackgroundColor
        layer.borderColor = theme.inputFieldBorderBackgroundColor.cgColor
        
        aboutTextViewPlaceholder.text = placeholder
    }
}

extension TextViewWithPlaceholder: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        aboutTextViewPlaceholder.isHidden = !text.isEmpty
        textDelegate?.textViewDidChange?(textView)
    }
}
