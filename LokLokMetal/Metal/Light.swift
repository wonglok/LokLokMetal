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
    var shininess: Float // object shininess instead of light shininess
    var specularIntensity: Float
    
    static func size() -> Int {
        //return MemoryLayout<Float>.size * 10// wont work
        return MemoryLayout<Float>.size * 12// work
        
        /*
         _______________________
         |0 1 2 3|4 5 6 7|8 9    |
         -----------------------
         |       |       |       |
         | chunk0| chunk1| chunk2|
         */
    }
    
    func raw() -> [Float] {
        let raw = [color.0, color.1, color.2, ambientIntensity, direction.0, direction.1, direction.2, diffuseIntensity, shininess, specularIntensity]
        return raw
    }
}
