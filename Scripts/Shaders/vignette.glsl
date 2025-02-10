extern vec2 resolution;
extern number radius;
extern number softness;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec2 position = (screen_coords / resolution) - 0.5;
    float len = length(position) * 2.0; // Normalize distance for full screen coverage

    // Vignette calculation
    float vignette = smoothstep(radius, radius - softness, len);

    // Apply the vignette effect
    vec4 texcolor = Texel(texture, texture_coords);
    texcolor.rgb *= mix(0.0, 1.0, vignette); // Smooth transition from center to edges

    return texcolor * color;
}