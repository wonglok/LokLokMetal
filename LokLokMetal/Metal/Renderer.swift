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
    
    var start = mach_absolute_time()
    var deltaTime = mach_absolute_time()
    
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
        makeRenderable()
    }
    
    func makeCamera (view: UIView) {
        projectionMatrix = Matrix4.makePerspectiveViewAngle(
            Matrix4.degrees(toRad: 85.0),
            aspectRatio: Float(view.bounds.size.width / view.bounds.size.height),
            nearZ: 0.01,
            farZ: 100.0
        )
    }
    
    func makeRenderable () {
        objectToDraw = Cube(device: device)
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
        
        let end = mach_absolute_time()
        let deltaTime = Float(end - start) * 0.00000001
        start = end
        
        guard   let drawable = view.currentDrawable // ,
                //let descriptor = view.currentRenderPassDescriptor
                //let commandBuffer = commandQueue.makeCommandBuffer(),
                //let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)
        else { return }
        
        let worldModelMatrix = Matrix4()
        worldModelMatrix.translate(0.0, y: 0.0, z: -7.0)
        worldModelMatrix.rotateAroundX(Matrix4.degrees(toRad: 25), y: 0.0, z: 0.0)
        
        objectToDraw.updateWithDelta(delta: deltaTime)
        
        objectToDraw.render(
            commandQueue: commandQueue,
            pipelineState: pipelineState,
            drawable: drawable,
            parentModelViewMatrix: worldModelMatrix,
            projectionMatrix: projectionMatrix,
            clearColor: nil
        )
        
        
        
    }
}
