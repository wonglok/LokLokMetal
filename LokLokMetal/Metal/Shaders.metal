//
//  Shaders.metal
//  LokLokMetal
//
//  Created by LOK on 1/8/2017.
//  Copyright © 2017 WONG LOK. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

vertex float4 basic_vertex(                           // 1
                           const device packed_float3* vertex_array [[ buffer(0) ]], // 2
                           unsigned int vid [[ vertex_id ]]) {                 // 3
    return float4(vertex_array[vid], 1.0);              // 4
}

fragment half4 basic_fragment() { // 1
    return half4(1.0);              // 2
}
