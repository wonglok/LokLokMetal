//
//  Node.swift
//  LokLokMetal
//
//  Created by LOK on 1/8/2017.
//  Copyright © 2017 WONG LOK. All rights reserved.
//

import Foundation
import Metal
import MetalKit
import GLKit
import QuartzCore

class Node {
    
    var time: Float = 0.0
    
    let device: MTLDevice
    let name: String
    var vertexCount: Int
    var vertexBuffer: MTLBuffer!
    
    var bufferProvider: BufferProvider
    
    var nodeModelMatrix: Matrix4!
    
    var positionX: Float = 0.0
    var positionY: Float = 0.0
    var positionZ: Float = 0.0
    
    var rotationX: Float = 0.0
    var rotationY: Float = 0.0
    var rotationZ: Float = 0.0
    var scale: Float     = 1.0
    
    init(name: String, vertices: [Vertex], device: MTLDevice){
        // 1
        var vertexData = [Float]()
        for vertex in vertices{
            vertexData += vertex.floatBuffer()
        }
        
        // 2
        let dataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0])
        try! vertexBuffer = device.makeBuffer(bytes: vertexData, length: dataSize, options: [])

        // 3
        self.name = name
        self.device = device
        vertexCount = vertices.count
        
        self.bufferProvider = BufferProvider(device: device, inflightBuffersCount: 3, sizeOfUniformsBuffer: MemoryLayout<Float>.size * Matrix4.numberOfElements() * 2)
        prepMatrix()
    }
    
    func prepMatrix () {
        nodeModelMatrix = modelMatrix()
    }
    
    func handleMatrix (renderEncoder: MTLRenderCommandEncoder, projectionMatrix: Matrix4, parentModelViewMatrix: Matrix4) {
        // 1
        nodeModelMatrix = modelMatrix()
        nodeModelMatrix.multiplyLeft(parentModelViewMatrix)
        
        let uniformBuffer = bufferProvider.nextUniformsBuffer(projectionMatrix: projectionMatrix, modelViewMatrix: nodeModelMatrix)
        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
    }
    
    func updateWithDelta (delta: Float) {
        time += delta
    }
    
    func render(
        commandQueue: MTLCommandQueue,
        pipelineState: MTLRenderPipelineState,
        drawable: CAMetalDrawable,
        parentModelViewMatrix: Matrix4,
        projectionMatrix: Matrix4,
        clearColor: MTLClearColor?
    ) {
        bufferProvider.configTryWait()
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor =
            MTLClearColor(red: 0.0, green: 104.0/255.0, blue: 5.0/255.0, alpha: 1.0)
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        
        let commandBuffer = commandQueue.makeCommandBuffer()!
        bufferProvider.configResourceRestore(commandBuffer: commandBuffer)
        
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        renderEncoder.setCullMode(MTLCullMode.front)
        
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        
        handleMatrix(renderEncoder: renderEncoder,
                     projectionMatrix: projectionMatrix,
                     parentModelViewMatrix: parentModelViewMatrix)
        
        renderEncoder.drawPrimitives(
                                        type: .triangle,
                                        vertexStart: 0,
                                        vertexCount: vertexCount,
                                        instanceCount: vertexCount / 3
                                    )
        
        renderEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    func modelMatrix() -> Matrix4 {
        let matrix = Matrix4()
        matrix.translate(positionX, y: positionY, z: positionZ)
        matrix.rotateAroundX(rotationX, y: rotationY, z: rotationZ)
        matrix.scale(scale, y: scale, z: scale)
        return matrix
    }
    
}
