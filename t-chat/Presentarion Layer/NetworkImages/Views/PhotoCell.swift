//
//  PhotoCellCollectionViewCell.swift
//  t-chat
//
//  Created by Артур Гнедой on 18.11.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell, ConfigurableView {
    
    var image: UIImage? {
        didSet {
            if let image = image {
                imageView.image = image
                imageView.isHidden = false
                
                activityIndicator.isHidden = true
            }
        }
    }
    
    func showActivityIndicator() {
        imageView.isHidden = true
        
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
    }

    private var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .gray)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.isHidden = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(activityIndicator)
        contentView.addSubview(imageView)
        
        imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    typealias ConfigurationModel = NetworkPhoto
    
    func configure(with model: NetworkPhoto, theme: Theme?) {
        
    }
}
