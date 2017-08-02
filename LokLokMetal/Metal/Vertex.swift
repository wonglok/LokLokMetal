//
//  Vertex.swift
//  LokLokMetal
//
//  Created by LOK on 1/8/2017.
//  Copyright © 2017 WONG LOK. All rights reserved.
//

import Foundation

struct Vertex{
    
    var x,y,z: Float     // position data
    var r,g,b,a: Float   // color data
    var s,t: Float       // texture coordinates
    
    func floatBuffer() -> [Float] {
        return [x,y,z,r,g,b,a,s,t]
    }
    
};
