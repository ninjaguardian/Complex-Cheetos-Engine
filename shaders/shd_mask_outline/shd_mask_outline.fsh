varying vec2 v_vTexcoord;
uniform sampler2D u_mask;
uniform vec2 u_texelSize;   // (1.0/width, 1.0/height)
uniform vec4 u_outlinecolor;

void main() {
    float c = texture2D(u_mask, v_vTexcoord).a;
    // sample 4 neighbors
    vec2 off = u_texelSize;
    float m1 = texture2D(u_mask, v_vTexcoord + vec2(off.x, 0)).a;
    float m2 = texture2D(u_mask, v_vTexcoord + vec2(-off.x, 0)).a;
    float m3 = texture2D(u_mask, v_vTexcoord + vec2(0, off.y)).a;
    float m4 = texture2D(u_mask, v_vTexcoord + vec2(0, -off.y)).a;

    // outward: current outside, neighbor inside
    if (c < 0.5 && (m1 > 0.5 || m2 > 0.5 || m3 > 0.5 || m4 > 0.5)) {
        gl_FragColor = u_outlinecolor;
    } else {
        discard;
    }
}
