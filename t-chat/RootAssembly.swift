//
//  RootAssembly.swift
//  t-chat
//
//  Created by Артур Гнедой on 13.11.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import Foundation

final class RootAssembly {
    private lazy var coreAssembly: CoreAssembly = CoreAssemblyImplementation()
    
    private lazy var serviceAssembly: ServiceAssembly = ServiceAssemblyImplementation(coreAssembly: self.coreAssembly)
    
    lazy var presentationAssembly: PresentationAssembly = PresentationAssemblyImplementation(serviceAssembly: self.serviceAssembly)
    
}
