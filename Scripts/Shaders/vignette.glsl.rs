-- vignette.glsl

extern vec2 resolution;
extern number radius;
extern number softness;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec2 position = (screen_coords / resolution) - 0.5;
    float len = length(position);
    
    // Vignette calculation
    float vignette = smoothstep(radius, radius - softness, len);

    // Apply the vignette effect
    vec4 texcolor = Texel(texture, texture_coords);
    texcolor.rgb *= (1.0 - vignette);

    return texcolor * color;
}