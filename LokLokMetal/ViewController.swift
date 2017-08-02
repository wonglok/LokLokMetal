//
//  ViewController.swift
//  LokLokMetal
//
//  Created by LOK on 1/8/2017.
//  Copyright © 2017 WONG LOK. All rights reserved.
//

import UIKit
import MetalKit

enum Colors {
    static let wenderlichGreen = MTLClearColor(red: 0.0,
                                               green: 0.4,
                                               blue: 0.21,
                                               alpha: 1.0)
    static let white = MTLClearColor(red: 1.0,
                                     green: 1.0,
                                     blue: 1.0,
                                     alpha: 1.0)
    
    static let black = MTLClearColor(red: 0.0,
                                     green: 0.0,
                                     blue: 0.0,
                                     alpha: 1.0)
    
    static let transparent = MTLClearColor(red: 0.0,
                                     green: 0.0,
                                     blue: 0.0,
                                     alpha: 0.0)

}


class ViewController: UIViewController {
    
    var metalView: MTKView {
        return view as! MTKView
    }

    var renderer: Renderer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        metalView.device = MTLCreateSystemDefaultDevice()
        guard let device = metalView.device else {
            fatalError("Device not created. Run on a physical device")
        }
        
        metalView.clearColor =  Colors.wenderlichGreen
        renderer = Renderer(device: device, view: view)
        metalView.preferredFramesPerSecond = 120
        metalView.delegate = renderer
    }
}






