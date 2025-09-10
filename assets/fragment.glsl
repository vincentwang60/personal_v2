precision mediump float;

#define PI 3.14159
uniform float u_time;
uniform vec2 u_resolution;
uniform vec2 u_mouse;

vec3 hsv2rgb(vec3 c) {
    vec3 p = abs(fract(c.xxx + vec3(1.0, 2.0/3.0, 1.0/3.0)) * 6.0 - 3.0) - 1.0;
    return c.z * mix(vec3(1.0), clamp(p, 0.0, 1.0), c.y);
}

vec2 noise(vec2 _uv, float time, float seed) {
    float safe_time = time + seed;

    float factor1 = .05, freq1 = 1.0;
    float sin1 = sin(freq1 * _uv.y + safe_time);
    float cos1 = cos(freq1 * _uv.x + safe_time);
    _uv.x += factor1 * sin1;
    _uv.y += factor1 * cos1;
    
    float factor2 = 0.02, freq2 = 10.0 + seed;
    float sin2 = sin(freq2 * _uv.y + safe_time);
    float cos2 = cos(freq2 * _uv.x + safe_time);
    _uv.x += factor2 * sin2;
    _uv.y += factor2 * cos2;
    
    return _uv;
}

void main() {
    float time = u_time * 2.;
    float scale = 2.0 / (min(u_resolution.x, u_resolution.y));
    vec2 mouse_norm = u_mouse / u_resolution;
    float seed = (mouse_norm.x + mouse_norm.y);
    vec2 pos = gl_FragCoord.xy - u_resolution * 0.5;
    float radius = length(pos) * scale;
    float angle = fract(atan(pos.y, pos.x) / (2.0 * PI));
    
    float x = radius * cos(angle * 2.0 * PI);
    float y = radius * sin(angle * 2.0 * PI);
    vec2 mask_uv = noise(vec2(x, y), time, seed);
    mask_uv *= mask_uv;    
    float intensity = fract(mask_uv.x + mask_uv.y);
    vec3 color = hsv2rgb(vec3(0.1 + 0.01 * sin(time), 1.0, 0.25 * intensity));
    
    gl_FragColor = vec4(color, 1.0);
}