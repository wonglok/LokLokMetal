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
    
    let light = Light(color: (1.0,1.0,1.0), ambientIntensity: 0.2, direction: (0.0, 0.0, 1.0), diffuseIntensity: 0.8)
    
    var time: Float = 0.0
    
    let device: MTLDevice!
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
    
    var texture: MTLTexture
    lazy var samplerState: MTLSamplerState? = Node.defaultSampler(device: self.device)
    
    init(name: String, vertices: [Vertex], device: MTLDevice, texture: MTLTexture){
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
        
        self.texture = texture
        
//        self.bufferProvider = BufferProvider(device: device, inflightBuffersCount: 3, sizeOfUniformsBuffer: MemoryLayout<Float>.size * Matrix4.numberOfElements() * 2)
        
        let sizeOfUniformsBuffer = MemoryLayout<Float>.size * Matrix4.numberOfElements() * 2 + Light.size()
        self.bufferProvider = BufferProvider(device: device, inflightBuffersCount: 3, sizeOfUniformsBuffer: sizeOfUniformsBuffer)
        
        
        
        prepMatrix()
    }
    
    func prepMatrix () {
        nodeModelMatrix = modelMatrix()
    }
    
    func handleMatrix (renderEncoder: MTLRenderCommandEncoder, projectionMatrix: Matrix4, parentModelViewMatrix: Matrix4) {
        // 1
        nodeModelMatrix = modelMatrix()
        nodeModelMatrix.multiplyLeft(parentModelViewMatrix)
        
        let uniformBuffer = bufferProvider.nextUniformsBuffer(projectionMatrix: projectionMatrix, modelViewMatrix: nodeModelMatrix, light: light)
        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
        renderEncoder.setFragmentBuffer(uniformBuffer, offset: 0, index: 1)
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
            MTLClearColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        
        let commandBuffer = commandQueue.makeCommandBuffer()!
        bufferProvider.configResourceRestore(commandBuffer: commandBuffer)
        
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        renderEncoder.setCullMode(MTLCullMode.front)
        
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        
        renderEncoder.setFragmentTexture(texture, index: 0)
        if let samplerState = samplerState{
            renderEncoder.setFragmentSamplerState(samplerState, index: 0)
        }
        
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
    
    class func defaultSampler(device: MTLDevice) -> MTLSamplerState {
        let sampler = MTLSamplerDescriptor()
        sampler.minFilter             = MTLSamplerMinMagFilter.nearest
        sampler.magFilter             = MTLSamplerMinMagFilter.nearest
        sampler.mipFilter             = MTLSamplerMipFilter.nearest
        sampler.maxAnisotropy         = 1
        sampler.sAddressMode          = MTLSamplerAddressMode.clampToEdge
        sampler.tAddressMode          = MTLSamplerAddressMode.clampToEdge
        sampler.rAddressMode          = MTLSamplerAddressMode.clampToEdge
        sampler.normalizedCoordinates = true
        sampler.lodMinClamp           = 0
        sampler.lodMaxClamp           = Float.greatestFiniteMagnitude
        return device.makeSamplerState(descriptor: sampler)!
    }
    
}
