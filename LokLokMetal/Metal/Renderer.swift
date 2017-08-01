//
//  Renderer.swift
//  LokLokMetal
//
//  Created by LOK on 1/8/2017.
//  Copyright © 2017 WONG LOK. All rights reserved.
//

import MetalKit

struct LokVertex {
    var position: vector_float4
    var color: vector_float4
}

class Renderer: NSObject {
    let device: MTLDevice!
    let commandQueue: MTLCommandQueue!
    
    let pipelineDescriptor = MTLRenderPipelineDescriptor()
    var pipelineState: MTLRenderPipelineState!
    
//    var objectToDraw: Triangle!
    var objectToDraw: Cube!
    var projectionMatrix: Matrix4!
    


    init(device: MTLDevice, view: UIView) {
        self.device = device
        commandQueue = device.makeCommandQueue()
        super.init()
        makeLib()
        makeCamera(view: view)
        makeBuffers()
    }
    
    func makeCamera (view: UIView) {
        projectionMatrix = Matrix4.makePerspectiveViewAngle(
            Matrix4.degrees(toRad: 85.0),
            aspectRatio: Float(view.bounds.size.width / view.bounds.size.height),
            nearZ: 0.01,
            farZ: 100.0
        )
    }
    
    func makeBuffers () {
        objectToDraw = Cube(device: device)
        
        objectToDraw.positionX =  0.0
        objectToDraw.positionY =  0.0
        objectToDraw.positionZ = -2.0
        objectToDraw.rotationZ = Matrix4.degrees(toRad: 45);
        objectToDraw.scale = 0.5
    }
    func makeLib () {
        // 1
        let defaultLibrary = device.makeDefaultLibrary()!
        let fragmentProgram = defaultLibrary.makeFunction(name: "basic_fragment")
        let vertexProgram = defaultLibrary.makeFunction(name: "basic_vertex")

        // 2
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        // 3
        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
    }
}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) { }
    
    func draw(in view: MTKView) {
        guard   let drawable = view.currentDrawable // ,
                //let descriptor = view.currentRenderPassDescriptor
                //let commandBuffer = commandQueue.makeCommandBuffer(),
                //let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)
        else { return }
        
        objectToDraw.render(
            commandQueue: commandQueue,
            pipelineState: pipelineState,
            drawable: drawable,
            projectionMatrix: projectionMatrix,
            clearColor: nil
        )
        
        
    }
}
