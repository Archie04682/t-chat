//
//  ConfigurableView.swift
//  t-chat
//
//  Created by Артур Гнедой on 25.09.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

protocol ConfigurableView {
    
    associatedtype ConfigurationModel
    
    func configure(with model: ConfigurationModel, theme: Theme?)
    
}
