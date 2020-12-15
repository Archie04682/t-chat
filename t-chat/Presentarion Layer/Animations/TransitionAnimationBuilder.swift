//
//  Rotation.swift
//  t-chat
//
//  Created by Артур Гнедой on 25.11.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import Foundation
import UIKit

final class TransitionAnimationBuilder {
    
    private var group: CAAnimationGroup
    private var animations: [CAAnimation] = []
    
    init(duration: Double, repeatCount: Float) {
        group = CAAnimationGroup()
        group.duration = duration
        group.repeatCount = repeatCount
        group.autoreverses = true
    }
    
    func build() -> CAAnimationGroup {
        group.animations = animations
        return group
    }
    
    func addRotation(withAngle angle: Double, reverseRotation: Bool = true) {
        let rotationAngle = CGFloat(Double.pi / 180 * angle)
        let animation = CABasicAnimation(keyPath: #keyPath(CALayer.transform))
        animation.toValue = CATransform3DMakeRotation(rotationAngle, 0, 0, 1)
        
        if reverseRotation {
            animation.fromValue = CATransform3DMakeRotation(-rotationAngle, 0, 0, 1)
        }
        
        animations.append(animation)
    }
    
    func addPositionTransition(withIntent intent: Double, direction: Direction, reverse: Bool = false) {
        let animation = CAKeyframeAnimation(keyPath: direction == Direction.vertical ? "transform.translation.y" : "transform.translation.x")
        let delta = CGFloat(intent)
        animation.values = [0, delta, 0]

        if reverse {
            animation.values?.append(-delta)
            animation.keyTimes = [0, 0.33, 0.66, 1]
        } else {
            animation.keyTimes = [0, 0.5, 1]
        }

        animations.append(animation)
    }
}

enum Direction {
    case vertical
    case horizontal
}
