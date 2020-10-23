//
//  TCProfileImageView.swift
//  t-chat
//
//  Created by Артур Гнедой on 22.09.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import UIKit

class ProfileImageView: UIView {
    
    private var initialsLabel: UILabel?
    private var photoImageView: UIImageView?
    
//    var initials: String? {
//        didSet {
//            photoImageView?.removeFromSuperview()
//            photoImageView = nil
//            if let l = initialsLabel {
//                l.text = initials
//            } else {
//                let label = UILabel()
//                label.text = initials
//                label.font = UIFont.systemFont(ofSize: frame.width / 2)
//                label.textAlignment = .center
//                label.textColor = .black
//                addSubview(label)
//                center(child: label)
//                initialsLabel = label
//            }
//        }
//    }
    
    var image: UIImage? {
        didSet {
            initialsLabel?.removeFromSuperview()
            initialsLabel = nil
            if let view = photoImageView {
                view.image = image
            } else {
                let imageView = UIImageView(image: image)
                imageView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height   )
                imageView.layer.cornerRadius = imageView.frame.width / 2
                imageView.contentMode = UIView.ContentMode.scaleAspectFill
                imageView.clipsToBounds = true
                addSubview(imageView)
                
                center(child: imageView)
                imageView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
                imageView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
                
                photoImageView = imageView
            }
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    override init (frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    private func setupView() {
        layer.cornerRadius = frame.width / 2
    }
    
    private func center(child view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        view.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        view.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    func setInitials(username: String) {
        photoImageView?.removeFromSuperview()
        photoImageView = nil
        let initials = convertToInitials(username)
        if let l = initialsLabel {
            l.text = initials
        } else {
            let label = UILabel()
            label.text = initials
            label.font = UIFont.systemFont(ofSize: frame.width / 2)
            label.textAlignment = .center
            label.textColor = .black
            addSubview(label)
            center(child: label)
            initialsLabel = label
        }
    }
    
    private func convertToInitials(_ str: String) -> String {
        let components = str.components(separatedBy: " ").filter { !$0.isEmpty }
        if components.count <= 0 { return "" }
        if components.count <= 2 {
            return components.map { word in
                if let firstLetter = word.first {
                    return String(firstLetter)
                }

                return ""
            }.joined()
        }
        
        return "\(components.first ?? "")\(components.last ?? "")"
    }
    
}

extension UILabel {
    
    func setLetterSpacing(value: Double) {
        if let text = text, !text.isEmpty {
            let attributedString = NSMutableAttributedString(string: text)
            attributedString.addAttribute(.kern, value: value, range: NSRange(location: 0, length: attributedString.length - 1))
            self.attributedText = attributedString
        }
    }
    
}
