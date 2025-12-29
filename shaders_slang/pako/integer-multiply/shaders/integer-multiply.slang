#version 450

// blendmultiply
// based on:
// https://github.com/jamieowen/glsl-blend for blendMultiply

layout(push_constant) uniform Push
{
	vec4 SourceSize;
	vec4 OriginalSize;
	vec4 OutputSize;
	uint FrameCount;
	float MultiplyMix;
	float MultiplyComp;
	float MultiplyLUTWidth;
	float MultiplyLUTHeight;
	float BGR;
} params;

#pragma parameter MultiplyMix "Multiply Mix" 1.0 0.0 1.0 0.05
#pragma parameter MultiplyComp "Brightness Compensation" 0.0 0.0 1.0 0.05
#pragma parameter MultiplyLUTWidth "Multiply LUT Width" 6.0 1.0 1920.0 1.0
#pragma parameter MultiplyLUTHeight "Multiply LUT Height" 4.0 1.0 1920.0 1.0
#pragma parameter BGR "Swap Red-Blue" 0.0 0.0 1.0 1.0

#define MultiplyMix params.MultiplyMix
#define MultiplyComp params.MultiplyComp
#define MultiplyLUTWidth params.MultiplyLUTWidth
#define MultiplyLUTHeight params.MultiplyLUTHeight
#define BGR params.BGR

layout(std140, set = 0, binding = 0) uniform UBO
{
	mat4 MVP;
} global;

#pragma stage vertex
layout(location = 0) in vec4 Position;
layout(location = 1) in vec2 TexCoord;
layout(location = 0) out vec2 vTexCoord;

void main()
{
   gl_Position = global.MVP * Position;
   vTexCoord = TexCoord;
}

#pragma stage fragment
layout(location = 0) in vec2 vTexCoord;
layout(location = 0) out vec4 FragColor;
layout(set = 0, binding = 2) uniform sampler2D Source;
layout(set = 0, binding = 3) uniform sampler2D multiply;

void main()
{
    vec3 Picture = texture(Source, vTexCoord).xyz;

    vec2 LutCoord = vec2(fract(vTexCoord.x*params.OutputSize.x/MultiplyLUTWidth),fract(vTexCoord.y*params.OutputSize.y/MultiplyLUTHeight));

    vec3 ShadowMask = texture(multiply, LutCoord).xyz;
    
    vec3 ImageFinal = Picture;
    
    ImageFinal.r = ImageFinal.r*(ShadowMask.r*(1.0-BGR)+ShadowMask.b*BGR);
    ImageFinal.g = ImageFinal.g*ShadowMask.g;
    ImageFinal.b = ImageFinal.b*(ShadowMask.b*(1.0-BGR)+ShadowMask.r*BGR);
    
    ImageFinal = clamp((mix(Picture,clamp(ImageFinal,0.0,1.0),MultiplyMix))*(1.0+(MultiplyComp/4.0)),0.0,1.0);

    FragColor = vec4(ImageFinal,1.0);
}
