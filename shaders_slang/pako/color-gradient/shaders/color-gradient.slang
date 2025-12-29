#version 450

// color-gradient (2 point)

layout(push_constant) uniform Push
{
	vec4 SourceSize;
	vec4 OriginalSize;
	vec4 OutputSize;
	uint FrameCount;
	float GradBase;
	float Grad1R;
	float Grad1G;
	float Grad1B;
	float Grad2R;
	float Grad2G;
	float Grad2B;
} params;


#pragma parameter GradBase "Gradient Base - Luminance: 0, RGB Average: 1" 0.0 0.0 1.0 1.0

#pragma parameter Grad1R "Gradient Color 1 R" 0.0 0.0 1.0 0.01
#pragma parameter Grad1G "Gradient Color 1 G" 0.0 0.0 1.0 0.01
#pragma parameter Grad1B "Gradient Color 1 B" 0.0 0.0 1.0 0.01

#pragma parameter Grad2R "Gradient Color 2 R" 1.0 0.0 1.0 0.01
#pragma parameter Grad2G "Gradient Color 2 G" 1.0 0.0 1.0 0.01
#pragma parameter Grad2B "Gradient Color 2 B" 1.0 0.0 1.0 0.01

#define GradBase params.GradBase
#define Grad1R params.Grad1R
#define Grad1G params.Grad1G
#define Grad1B params.Grad1B
#define Grad2R params.Grad2R
#define Grad2G params.Grad2G
#define Grad2B params.Grad2B

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

void main()
{
    vec3 Picture = texture(Source, vTexCoord).xyz;

    float Luminance =	Picture.x*((0.299*(1.0-GradBase))+(0.333*GradBase)) + 
						Picture.y*((0.587*(1.0-GradBase))+(0.333*GradBase)) + 
						Picture.z*((0.114*(1.0-GradBase))+(0.333*GradBase));
    
    vec3 ImageFinal = Picture;
    
    ImageFinal.r = mix(Grad1R, Grad2R, Luminance);
    ImageFinal.g = mix(Grad1G, Grad2G, Luminance);
    ImageFinal.b = mix(Grad1B, Grad2B, Luminance);
    
    FragColor = vec4(ImageFinal,1.0);
}
