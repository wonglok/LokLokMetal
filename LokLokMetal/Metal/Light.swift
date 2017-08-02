//
//  Light.swift
//  LokLokMetal
//
//  Created by LOK on 3/8/2017.
//  Copyright © 2017 WONG LOK. All rights reserved.
//

import Foundation

struct Light {
    
    var color: (Float, Float, Float)  // 1
    var ambientIntensity: Float       // 2
    var direction: (Float, Float, Float)
    var diffuseIntensity: Float
    
    static func size() -> Int {
        return MemoryLayout<Float>.size * 8
    }
    
    func raw() -> [Float] {
        let raw = [color.0, color.1, color.2, ambientIntensity, direction.0, direction.1, direction.2, diffuseIntensity]
        return raw
    }
}
