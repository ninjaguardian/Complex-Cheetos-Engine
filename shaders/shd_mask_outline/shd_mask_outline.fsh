#ifdef GL_ES
precision mediump float;
#endif
varying vec2 v_vTexcoord;
uniform sampler2D u_mask;
uniform vec2 u_texelSize;
uniform vec4 u_outlinecolor;
uniform float u_outlineRadius;
uniform int u_mode;
const int MAX_RADIUS = 10;

float computeDistance(float dx, float dy, int type) {
    if (type == 0) {
        // Chebyshev (square)
        return max(abs(dx), abs(dy));
    } else if (type == 1) {
        // Manhattan (diamond)
        return abs(dx) + abs(dy);
    } else {
        // Circular (Euclidean)
        return length(vec2(dx, dy)); // TODO: should bevel inside too
    }
}

void main() {
    float c = texture2D(u_mask, v_vTexcoord).a;
    if (c < 0.5) {
        for (int dy = -MAX_RADIUS; dy <= MAX_RADIUS; dy++) {
            for (int dx = -MAX_RADIUS; dx <= MAX_RADIUS; dx++) {
                if (dx == 0 && dy == 0) continue;
                float fdx = float(dx);
                float fdy = float(dy);
                if (computeDistance(fdx, fdy, u_mode) > u_outlineRadius) continue;
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