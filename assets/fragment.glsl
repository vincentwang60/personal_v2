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
    float time_seed = time + seed;
    float sin1 = sin(_uv.y + time_seed), cos1 = cos(_uv.x + time_seed);
    _uv += 0.05 * vec2(sin1, cos1);
    
    float freq2 = 10.0 + seed;
    float sin2 = sin(freq2 * _uv.y + time_seed), cos2 = cos(freq2 * _uv.x + time_seed);
    _uv += 0.02 * vec2(sin2, cos2);
    
    return _uv;
}

void getVec2Array(out vec2 arr[7]) {
    for (int i = 0; i < 6; ++i) {
        float r = 0.1 + 0.001 * sin(u_time + float(i) * 0.5);
        float angle = 2.0 * PI * float(i) / 6.0 + 0.05 * sin(u_time + float(i) * 2.5) + PI / 6.0;
        arr[i] = r * vec2(cos(angle), sin(angle));
    }
    arr[6] = vec2(0.0);
}

vec3 voronoi(vec2 uv) {
    vec2 points[7];
    getVec2Array(points);
    float d1 = 1e9, d2 = 1e9;
    int idx = 0;
    for (int i = 0; i < 7; ++i) {
        float d = length(uv - points[i]);
        if (d < d1) {
            d2 = d1; d1 = d; idx = i;
        } else if (d < d2) {
            d2 = d;
        }
    }
    return vec3(d1, d2, float(idx));
}

void main() {
    float time = u_time * 0.5;
    float scale = 2.5 / min(u_resolution.x, u_resolution.y);
    vec2 mouse_norm = u_mouse / u_resolution;
    float seed = mouse_norm.x + mouse_norm.y;
    vec2 pos = gl_FragCoord.xy - u_resolution * 0.5;
    float radius = length(pos) * scale;
    float angle = fract(atan(pos.y, pos.x) / (2.0 * PI));
    
    pos = radius * vec2(cos(angle * 2.0 * PI), sin(angle * 2.0 * PI));
    vec2 mask_uv = rings(pos, time, seed);
    mask_uv *= mask_uv;    
    float intensity = fract(mask_uv.x + mask_uv.y);
    vec3 bg_color = hsv2rgb(vec3(0.10, 0.6 + 0.15 * radius, (0.5 - 0.12 * radius) * intensity));
    
    vec3 vinfo = voronoi(pos);
    float c = vinfo.z + 1.0;
    vec3 voronoi_color = c == 7.0 
        ? vec3(0.0) 
        : hsv2rgb(vec3(0.11, 1.0 - 0.10 * mod(c, 3.0), 0.6 + 0.10 * mod(c, 3.0)));
    
    float diff = vinfo.y - vinfo.x;
    float edge = 1.0 - smoothstep(0.001, 0.002, abs(diff * radius));
    voronoi_color = mix(voronoi_color, vec3(0.0), edge);
    
    vec3 final_color = 
        (radius < 0.8) ? voronoi_color :
        (radius > 1.1) ? bg_color :
        (intensity < 0.5 ? bg_color : mix(voronoi_color, bg_color, smoothstep(0.8, 1.2, intensity)));
    
    gl_FragColor = vec4(final_color, 1.0);
}