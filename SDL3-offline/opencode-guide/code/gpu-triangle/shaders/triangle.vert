#version 450
// Fullscreen-free triangle: positions generated from gl_VertexIndex,
// so the C++ side needs zero vertex buffers. Color passed to fragment.
layout(location = 0) out vec3 vColor;

void main() {
    vec2 pos = vec2(0.0);
    vec3 col = vec3(1.0);
    if (gl_VertexIndex == 0) {
        pos = vec2(-0.6, -0.4);
        col = vec3(1.0, 0.2, 0.2);
    } else if (gl_VertexIndex == 1) {
        pos = vec2(0.6, -0.4);
        col = vec3(0.2, 1.0, 0.2);
    } else {
        pos = vec2(0.0, 0.6);
        col = vec3(0.2, 0.4, 1.0);
    }
    vColor = col;
    gl_Position = vec4(pos, 0.0, 1.0);
}
