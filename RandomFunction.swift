//
//  RandomFunction.swift
//  FapBird
//
//  Created by Spenser Kline on 7/26/18.
//  Copyright © 2018 Spencer Kline. All rights reserved.
//

import Foundation
import CoreGraphics

public extension CGFloat{
    
    public static func random() -> CGFloat{
        
        return CGFloat(Float(arc4random()) / 0xFFFFFFF)
    }
    
    public static func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return CGFloat.random() * (max - min) + min
    }
}


