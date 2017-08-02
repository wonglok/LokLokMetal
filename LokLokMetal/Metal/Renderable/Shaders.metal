//
//  Shaders.metal
//  LokLokMetal
//
//  Created by LOK on 1/8/2017.
//  Copyright © 2017 WONG LOK. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct Light{
    packed_float3 color;
    float ambientIntensity;
    packed_float3 direction;
    float diffuseIntensity;
    float shininess;
    float specularIntensity;
};

// 1
struct VertexIn{
    packed_float3 position;
    packed_float4 color;
    packed_float2 texCoord;
    packed_float3 normal;
};

struct VertexOut{
    float4 position [[position]];
    float4 color;
    float2 texCoord;
    float3 normal;
    float3 fragmentPosition;
};

struct Uniforms{
    float4x4 modelMatrix;
    float4x4 projectionMatrix;
    Light light;
};

vertex VertexOut basic_vertex(
                              const device VertexIn* vertex_array [[ buffer(0) ]],
                              const device Uniforms&  uniforms    [[ buffer(1) ]],
                              unsigned int vid [[ vertex_id ]]) {
    
    float4x4 mv_Matrix = uniforms.modelMatrix;
    float4x4 proj_Matrix = uniforms.projectionMatrix;
    
    VertexIn VertexIn = vertex_array[vid];
    
    VertexOut VertexOut;
    VertexOut.position = proj_Matrix * mv_Matrix * float4(VertexIn.position,1);
    VertexOut.fragmentPosition = (mv_Matrix * float4(VertexIn.position,1)).xyz;
    VertexOut.color = VertexIn.color;
    // 2
    VertexOut.texCoord = VertexIn.texCoord;
    VertexOut.normal = (mv_Matrix * float4(VertexIn.normal, 0.0)).xyz;
    return VertexOut;
}

fragment float4 basic_fragment(VertexOut         interpolated       [[stage_in]],
                               const device Uniforms&  uniforms    [[ buffer(1) ]],
                               texture2d<float>  tex2D              [[ texture(0) ]],
                               sampler           sampler2D          [[ sampler(0) ]]) {
    
    //    float4 color = tex2D.sample(sampler2D, interpolated.texCoord);
    Light light = uniforms.light;
    float4 ambientColor = float4(light.color * light.ambientIntensity, 1);
    //Diffuse
    float diffuseFactor = max(0.0,dot(interpolated.normal, light.direction)); // 1
    float4 diffuseColor = float4(light.color * light.diffuseIntensity * diffuseFactor ,1.0); // 2
    
    //Specular
    float3 eye = normalize(interpolated.fragmentPosition); //1
    float3 reflection = reflect(light.direction, interpolated.normal); // 2
    float specularFactor = pow(max(0.0, dot(reflection, eye)), light.shininess); //3
    float4 specularColor = float4(light.color * light.specularIntensity * specularFactor ,1.0);//4

    
    float4 color =  interpolated.color * tex2D.sample(sampler2D, interpolated.texCoord);
    return color * (ambientColor + diffuseColor + specularColor);
}
