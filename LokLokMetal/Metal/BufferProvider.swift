//
//  BufferProvider.swift
//  LokLokMetal
//
//  Created by LOK on 2/8/2017.
//  Copyright © 2017 WONG LOK. All rights reserved.
//

import Foundation
import Metal

class BufferProvider {
    var avaliableResourcesSemaphore: DispatchSemaphore
    
    // 1
    let inflightBuffersCount: Int
    // 2
    private var uniformsBuffers: [MTLBuffer]
    // 3
    private var avaliableBufferIndex: Int = 0
    
    let matrixMemorySize = MemoryLayout<Float>.size * Matrix4.numberOfElements()
    
    init(device:MTLDevice, inflightBuffersCount: Int, sizeOfUniformsBuffer: Int) {
        
        self.inflightBuffersCount = inflightBuffersCount
        uniformsBuffers = [MTLBuffer]()
        
        for _ in 0...inflightBuffersCount-1 {
            let uniformsBuffer = device.makeBuffer(length: sizeOfUniformsBuffer, options: [])
            uniformsBuffers.append(uniformsBuffer!)
        }
        
        avaliableResourcesSemaphore = DispatchSemaphore(value: inflightBuffersCount)
    }
    
    deinit{
        for _ in 0...self.inflightBuffersCount{
            self.avaliableResourcesSemaphore.signal()
        }
    }
    
    func configTryWait () {
        _ = avaliableResourcesSemaphore.wait(timeout: DispatchTime.distantFuture)
    }
    
    func configResourceRestore (commandBuffer: MTLCommandBuffer) {
        commandBuffer.addCompletedHandler { (_) in
            self.avaliableResourcesSemaphore.signal()
        }
    }
    
    func nextUniformsBuffer(projectionMatrix: Matrix4, modelViewMatrix: Matrix4) -> MTLBuffer {
        
        // 1
        let buffer = uniformsBuffers[avaliableBufferIndex]
        
        // 2
        let bufferPointer = buffer.contents()
        
        // 3
        memcpy(bufferPointer,                                modelViewMatrix.raw(),  matrixMemorySize)
        memcpy(bufferPointer.advanced(by: matrixMemorySize), projectionMatrix.raw(), matrixMemorySize)
        
        // 4
        avaliableBufferIndex += 1
        if avaliableBufferIndex == inflightBuffersCount{
            avaliableBufferIndex = 0
        }
        
        return buffer
    }
    
}
