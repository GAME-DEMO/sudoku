void main(void) {
    
    vec2 uv = v_tex_coord;
    vec2 center = vec2(0.5, 0.5);
    vec2 bottom = vec2(0.0, 0.0);
    
    float dist = distance(uv, center);
    float yDist = abs(uv.y - bottom.y - 0.5);
    
    vec3 centerColor = vec3(98.0 / 255.0, 255.0 / 255.0, 242.0 / 255.0);
    vec3 roundColor = vec3(33.0 / 255.0, 167.0 / 255.0, 150.0 / 255.0);
    
    gl_FragColor = vec4((roundColor.x - centerColor.x) * dist + centerColor.x,
                        (roundColor.y - centerColor.y) * dist + centerColor.y,
                        (roundColor.z - centerColor.z) * dist + centerColor.z,
                        1.0);
}