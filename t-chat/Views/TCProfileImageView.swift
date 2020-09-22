//
//  TCProfileImageView.swift
//  t-chat
//
//  Created by Артур Гнедой on 22.09.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import UIKit

class TCProfileImageView: UIView {
    
    private var initialsLabel: UILabel?
    private var photoImageView: UIImageView?
    
    var initials: String? {
        didSet {
            photoImageView?.removeFromSuperview()
            photoImageView = nil
            let label = UILabel()
            label.text = initials
            label.font = UIFont.systemFont(ofSize: frame.width / 2)
            label.textAlignment = .center
            addSubview(label)
            center(child: label)
            initialsLabel = label
        }
    }
    
    var image: UIImage? {
        didSet {
            initialsLabel?.removeFromSuperview()
            initialsLabel = nil
            let imageView = UIImageView(image: image)
            imageView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height   )
            imageView.layer.cornerRadius = imageView.frame.width / 2
            imageView.contentMode = UIView.ContentMode.scaleAspectFill
            imageView.clipsToBounds = true
            addSubview(imageView)
            center(child: imageView)
            photoImageView = imageView
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
        view.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        view.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
    }
    
}