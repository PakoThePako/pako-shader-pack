// version directive if necessary

// color-multiply
// based on:
// https://github.com/jamieowen/glsl-blend for blendMultiply

#pragma parameter GradBase "Gradient Base - Luminance: 0, RGB Average: 1" 0.0 0.0 1.0 1.0

#pragma parameter Grad1R "Gradient Color 1 R" 0.0 0.0 1.0 0.01
#pragma parameter Grad1G "Gradient Color 1 G" 0.0 0.0 1.0 0.01
#pragma parameter Grad1B "Gradient Color 1 B" 0.0 0.0 1.0 0.01

#pragma parameter Grad2R "Gradient Color 2 R" 1.0 0.0 1.0 0.01
#pragma parameter Grad2G "Gradient Color 2 G" 1.0 0.0 1.0 0.01
#pragma parameter Grad2B "Gradient Color 2 B" 1.0 0.0 1.0 0.01

#if defined(VERTEX)

#if __VERSION__ >= 130
#define COMPAT_VARYING out
#define COMPAT_ATTRIBUTE in
#define COMPAT_TEXTURE texture
#else
#define COMPAT_VARYING varying 
#define COMPAT_ATTRIBUTE attribute 
#define COMPAT_TEXTURE texture2D
#endif

#ifdef GL_ES
#define COMPAT_PRECISION mediump
#else
#define COMPAT_PRECISION
#endif

COMPAT_ATTRIBUTE vec4 VertexCoord;
COMPAT_ATTRIBUTE vec4 COLOR;
COMPAT_ATTRIBUTE vec4 TexCoord;
COMPAT_VARYING vec4 COL0;
COMPAT_VARYING vec4 TEX0;

vec4 _oPosition1; 
uniform mat4 MVPMatrix;
uniform COMPAT_PRECISION int FrameDirection;
uniform COMPAT_PRECISION int FrameCount;
uniform COMPAT_PRECISION vec2 OutputSize;
uniform COMPAT_PRECISION vec2 TextureSize;
uniform COMPAT_PRECISION vec2 InputSize;

// compatibility #defines
#define vTexCoord TEX0.xy
#define SourceSize vec4(TextureSize, 1.0 / TextureSize) //either TextureSize or InputSize
#define OutSize vec4(OutputSize, 1.0 / OutputSize)

void main()
{
    gl_Position = MVPMatrix * VertexCoord;
    TEX0.xy = TexCoord.xy;
}

#elif defined(FRAGMENT)

#ifdef GL_ES
#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif
#define COMPAT_PRECISION mediump
#else
#define COMPAT_PRECISION
#endif

#if __VERSION__ >= 130
#define COMPAT_VARYING in
#define COMPAT_TEXTURE texture
out COMPAT_PRECISION vec4 FragColor;
#else
#define COMPAT_VARYING varying
#define FragColor gl_FragColor
#define COMPAT_TEXTURE texture2D
#endif

uniform COMPAT_PRECISION int FrameDirection;
uniform COMPAT_PRECISION int FrameCount;
uniform COMPAT_PRECISION vec2 OutputSize;
uniform COMPAT_PRECISION vec2 TextureSize;
uniform COMPAT_PRECISION vec2 InputSize;
uniform sampler2D Texture;
uniform sampler2D multiply;
COMPAT_VARYING vec4 TEX0;

// compatibility #defines
#define Source Texture
#define vTexCoord TEX0.xy

#define SourceSize vec4(TextureSize, 1.0 / TextureSize) //either TextureSize or InputSize
#define OutSize vec4(OutputSize, 1.0 / OutputSize)

#ifdef PARAMETER_UNIFORM
uniform COMPAT_PRECISION float GradBase, Grad1R, Grad1G, Grad1B, Grad2R, Grad2G, Grad2B;
#else
#define GradBase 0.0
#define Grad1R 0.0
#define Grad1G 0.0
#define Grad1B 0.0
#define Grad2R 1.0
#define Grad2G 1.0
#define Grad2B 1.0

#endif

void main()
{
    vec3 Picture = COMPAT_TEXTURE(Source, vTexCoord).xyz;

    float Luminance =	Picture.x*((0.299*(1.0-GradBase))+(0.333*GradBase)) + 
						Picture.y*((0.587*(1.0-GradBase))+(0.333*GradBase)) + 
						Picture.z*((0.114*(1.0-GradBase))+(0.333*GradBase));
    
    vec3 ImageFinal = Picture;
    
    ImageFinal.r = mix(Grad1R, Grad2R, Luminance);
    ImageFinal.g = mix(Grad1G, Grad2G, Luminance);
    ImageFinal.b = mix(Grad1B, Grad2B, Luminance);
    
    FragColor = vec4(ImageFinal,1.0);
} 
#endif
