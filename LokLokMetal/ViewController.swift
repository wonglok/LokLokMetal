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
    
    let panSensivity:Float = 5.0
    var lastPanLocation: CGPoint!
    
    var metalView: MTKView {
        return view as! MTKView
    }

    var renderer: Renderer?
    
    func setupGestures(){
        let pan = UIPanGestureRecognizer(target: self, action: #selector(ViewController.pan))
        self.view.addGestureRecognizer(pan)
    }
    
    @objc func pan(panGesture: UIPanGestureRecognizer){
        if panGesture.state == UIGestureRecognizerState.changed {
            
            
            let pointInView = panGesture.location(in: self.view)
            // 3
            let xDelta = Float((lastPanLocation.x - pointInView.x)/self.view.bounds.width) * panSensivity
            let yDelta = Float((lastPanLocation.y - pointInView.y)/self.view.bounds.height) * panSensivity
            // 4
//            renderer?.objectToDraw.rotationY -= xDelta
//            renderer?.objectToDraw.rotationX -= yDelta
            
            renderer?.inertiaSim.move(dx: xDelta, dy: yDelta)
            
            lastPanLocation = pointInView
        } else if panGesture.state == UIGestureRecognizerState.began {
            lastPanLocation = panGesture.location(in: self.view)
        }
    }
    
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
        setupGestures()
    }
}






