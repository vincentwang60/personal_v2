precision mediump float;

#define PI 3.14159
uniform float u_time;
uniform vec2 u_resolution;
uniform vec2 u_mouse;

vec3 hsv2rgb(vec3 c) {
    vec3 p = abs(fract(c.xxx + vec3(1.0, 2.0/3.0, 1.0/3.0)) * 6.0 - 3.0) - 1.0;
    return c.z * mix(vec3(1.0), clamp(p, 0.0, 1.0), c.y);
}

vec2 rings(vec2 _uv, float time, float seed) {
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

void getVec2Array(out vec2 arr[7]) {
    for (int i = 0; i < 6; ++i) {
        float r = 0.05 + 0.01 * sin(u_time + float(i) * 0.5);
        float angle = 2.0 * PI * float(i) / 6.0 + 0.1 * (u_time) + 0.05 * sin(u_time + float(i) * 2.5);
        arr[i] = vec2(r * cos(angle), r * sin(angle));
    }
    arr[6] = vec2(0.0, 0.0);
}


float voronoi( in vec2 uv, in vec2 mouse )
{
    vec2 points[7];
    getVec2Array(points);
    float minDist = 100.0;
    int closestIndex = 0;
    
    for (int i = 0; i < 7; ++i) {
        float dist = length(uv - points[i]);
        if (dist < minDist) {
            minDist = dist;
            closestIndex = i;
        }
    }
    return float(closestIndex + 1);
}

void main() {
    float time = u_time * .5;
    float scale = 2.5 / (min(u_resolution.x, u_resolution.y));
    vec2 mouse_norm = u_mouse / u_resolution;
    float seed = (mouse_norm.x + mouse_norm.y);
    vec2 pos = gl_FragCoord.xy - u_resolution * 0.5;
    float radius = length(pos) * scale;
    float hue = 0.5 + .5 * sin(0.1 *u_time);
    float angle = fract(atan(pos.y, pos.x) / (2.0 * PI));
    
    pos = radius * vec2(cos(angle * 2.0 * PI), sin(angle * 2.0 * PI));
    vec2 mask_uv = rings(pos, time, seed);
    mask_uv *= mask_uv;    
    float intensity = fract(mask_uv.x + mask_uv.y);
    vec3 bg_color = hsv2rgb(vec3(hue + radius * .2, 1.0, 0.25 * intensity));
    
    float c = voronoi(pos, mouse_norm);
    vec3 voronoi_color = c == 7.0 
        ? vec3(0.0, 0.0, 0.0) 
        : hsv2rgb(vec3(0.5 + 0.1 * mod(c, 3.0), 0.5, 0.2));
    
    vec3 final_color = 
        (radius < 0.8) ? voronoi_color :
        (radius > 1.1) ? bg_color :
        (intensity < 0.5 ? bg_color : voronoi_color);
    
    gl_FragColor = vec4(final_color, 1.0);
}