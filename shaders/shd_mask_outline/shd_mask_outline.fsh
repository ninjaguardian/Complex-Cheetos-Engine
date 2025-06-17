varying vec2 v_vTexcoord;
uniform sampler2D u_mask;
uniform vec2 u_texelSize;   // (1.0/width, 1.0/height)
uniform vec4 u_outlinecolor;

void main() {
    float c = texture2D(u_mask, v_vTexcoord).a;

    vec2 off = u_texelSize;
    // orthogonal neighbors
    float m1 = texture2D(u_mask, v_vTexcoord + vec2( off.x,  0       )).a;
    float m2 = texture2D(u_mask, v_vTexcoord + vec2(-off.x,  0       )).a;
    float m3 = texture2D(u_mask, v_vTexcoord + vec2( 0,       off.y )).a;
    float m4 = texture2D(u_mask, v_vTexcoord + vec2( 0,      -off.y )).a;
    // diagonal neighbors
    float d1 = texture2D(u_mask, v_vTexcoord + vec2( off.x,  off.y )).a;
    float d2 = texture2D(u_mask, v_vTexcoord + vec2(-off.x,  off.y )).a;
    float d3 = texture2D(u_mask, v_vTexcoord + vec2( off.x, -off.y )).a;
    float d4 = texture2D(u_mask, v_vTexcoord + vec2(-off.x, -off.y )).a;

    // If current pixel is outside (alpha < 0.5) but any neighbor (orthogonal or diagonal) is inside (alpha > 0.5),
    // draw the outline color.
    if (c < 0.5 && (
            m1 > 0.5 || m2 > 0.5 || m3 > 0.5 || m4 > 0.5 ||
            d1 > 0.5 || d2 > 0.5 || d3 > 0.5 || d4 > 0.5
        )) {
        gl_FragColor = u_outlinecolor;
    } else {
        discard;
    }
}