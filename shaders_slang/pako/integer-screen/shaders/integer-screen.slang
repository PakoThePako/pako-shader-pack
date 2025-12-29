#version 450

// blendscreen
// based on:
// https://github.com/jamieowen/glsl-blend for blendScreen

layout(push_constant) uniform Push
{
	vec4 SourceSize;
	vec4 OriginalSize;
	vec4 OutputSize;
	uint FrameCount;
	float ScreenMix;
	float ScreenLUTWidth;
	float ScreenLUTHeight;
	float BGR;
} params;

#pragma parameter ScreenMix "Screen Mix" 1.0 0.0 1.0 0.05
#pragma parameter ScreenLUTWidth "Screen LUT Width" 6.0 1.0 1920.0 1.0
#pragma parameter ScreenLUTHeight "Screen LUT Height" 4.0 1.0 1920.0 1.0
#pragma parameter BGR "Swap Red-Blue" 0.0 0.0 1.0 1.0

#define ScreenMix params.ScreenMix
#define ScreenLUTWidth params.ScreenLUTWidth
#define ScreenLUTHeight params.ScreenLUTHeight
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
layout(set = 0, binding = 3) uniform sampler2D screen;

float blendScreen(float base, float blend) {
	return 1.0-((1.0-base)*(1.0-blend));
}

void main()
{
    vec3 Picture = texture(Source, vTexCoord).xyz;

    vec2 LutCoord = vec2(fract(vTexCoord.x*params.OutputSize.x/ScreenLUTWidth),fract(vTexCoord.y*params.OutputSize.y/ScreenLUTHeight));

    vec3 ShadowMask = texture(screen, LutCoord).xyz;
    
    vec3 ImageFinal = Picture;
    
	ImageFinal.r = blendScreen(ImageFinal.r,(ShadowMask.r*(1.0-BGR)+ShadowMask.b*BGR));
    ImageFinal.g = blendScreen(ImageFinal.g,ShadowMask.g);
    ImageFinal.b = blendScreen(ImageFinal.b,(ShadowMask.b*(1.0-BGR)+ShadowMask.r*BGR));
    
    ImageFinal = mix(Picture,clamp(ImageFinal,0.0,1.0),ScreenMix);
    
    FragColor = vec4(ImageFinal,1.0);
}
