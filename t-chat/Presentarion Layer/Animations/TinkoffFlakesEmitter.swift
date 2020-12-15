//
//  TinkoffFlakes.swift
//  t-chat
//
//  Created by Артур Гнедой on 25.11.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import UIKit

class TinkoffFlakesEmitter {
    lazy var flake: CAEmitterCell = {
        var cell = CAEmitterCell()
        cell.contents = UIImage(named: "tinkoff")?.cgImage
        cell.scale = 0.06
        cell.scaleRange = 0.3
        cell.emissionRange = .pi
        cell.lifetime = 1
        cell.birthRate = 5
        cell.velocity = 5
        cell.velocityRange = 15
        cell.xAcceleration = 20
        cell.yAcceleration = 15
        cell.spin = -0.5
        cell.spinRange = 1.0
        
        return cell
    }()
    
    func createLayer(position: CGPoint, size: CGSize) -> CAEmitterLayer {
        let flakeLayer = CAEmitterLayer()
        flakeLayer.emitterPosition = position
        flakeLayer.emitterSize = size
        flakeLayer.emitterShape = .point
        flakeLayer.beginTime = CACurrentMediaTime()
        flakeLayer.timeOffset = CFTimeInterval(arc4random_uniform(6) + 5)
        flakeLayer.emitterCells = [flake]
        return flakeLayer
    }
}
