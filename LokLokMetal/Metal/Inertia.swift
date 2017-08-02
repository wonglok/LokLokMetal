//
//  Inertia.swift
//  LokLokMetal
//
//  Created by LOK on 3/8/2017.
//  Copyright © 2017 WONG LOK. All rights reserved.
//

import Foundation


class Inertia {
    var mass: Float  = 3.0
    var reducer: Float = 0.98
    var inertia: Float = 0.0
    var stopper: Float = 0.001
    
    var dx: Float = 0.0
    var dy: Float = 0.0
    
    func move (dx x: Float, dy y: Float) {
        inertia = mass
        dx = x
        dy = y
    }
    func reduce () {
        if (inertia >= stopper) {
            inertia = inertia * reducer
        } else {
            inertia = 0.0
        }
    }
}
