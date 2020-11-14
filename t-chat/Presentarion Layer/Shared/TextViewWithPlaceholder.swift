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
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.sizeToFit()
        label.textColor = .gray
        
        label.isHidden = true
        return label
    }()
    
    func configure(placeholder: String, theme: Theme) {
//        translatesAutoresizingMaskIntoConstraints = false
        font = UIFont.systemFont(ofSize: 16, weight: .regular)
        aboutTextViewPlaceholder.frame.origin = CGPoint(x: 5, y: (font?.pointSize)! / 2)
        isScrollEnabled = false
        isHidden = true
        delegate = self
        layer.borderWidth = 1.5
        layer.cornerRadius = 4.0
        layer.masksToBounds = true
        
        addSubview(aboutTextViewPlaceholder)
        
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
