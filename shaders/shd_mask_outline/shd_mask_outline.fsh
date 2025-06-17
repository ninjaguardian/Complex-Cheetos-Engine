#ifdef GL_ES
precision mediump float;
#endif
varying vec2 v_vTexcoord;
uniform sampler2D u_mask;
uniform vec2 u_texelSize;
uniform vec4 u_outlinecolor;
uniform float u_outlineRadius;
const int MAX_RADIUS = 5;

void main() {
    float c = texture2D(u_mask, v_vTexcoord).a;
    if (c < 0.5) {
        for (int dy = -MAX_RADIUS; dy <= MAX_RADIUS; dy++) {
            for (int dx = -MAX_RADIUS; dx <= MAX_RADIUS; dx++) {
                if (dx == 0 && dy == 0) continue;
                // Radius types: Manhattan, Chebyshev, circular.
                // Current: Chebyshev (square) distance, max(|dx|,|dy|) ≤ u_outlineRadius
                float fdx = float(dx);
                float fdy = float(dy);
                float adx = abs(fdx);
                float ady = abs(fdy);
                if (max(adx, ady) > u_outlineRadius) continue;
                vec2 offset = vec2(fdx * u_texelSize.x, fdy * u_texelSize.y);
                float sampleA = texture2D(u_mask, v_vTexcoord + offset).a;
                if (sampleA > 0.5) {
                    gl_FragColor = u_outlinecolor;
                    return;
                }
            }
        }
    }
    discard;
}