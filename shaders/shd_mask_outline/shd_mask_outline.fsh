#ifdef GL_ES
#extension GL_OES_standard_derivatives : enable
precision mediump float;
#endif

varying vec2 v_vTexcoord;
uniform sampler2D u_mask;      // mask texture (alpha=1 inside)
uniform sampler2D u_border;    // border sprite, tileable horizontally
uniform float u_borderWidth;   // in pixels (e.g. 32.0)
uniform float u_thickness;     // border thickness in pixels
uniform vec2 u_viewSize;       // viewport size in pixels, e.g. (640,480) or pass via uniform
// optional: uniform vec4 u_tint;

void main() {
    // Sample mask alpha
    float a = texture2D(u_mask, v_vTexcoord).a;

    // Compute gradient of alpha in texture space
    float dx = dFdx(a);
    float dy = dFdy(a);
    vec2 grad = vec2(dx, dy);

    // If gradient is nearly zero, we’re far from any edge -> discard
    float gLen = length(grad);
    if (gLen < 0.0001) {
        discard;
    }

    // Approximate signed distance (positive outside, negative inside)
    float dist = (a - 0.5) / gLen; // in pixels

    // Only draw outer border: where dist in [0, u_thickness]
    if (dist < 0.0 || dist > u_thickness) {
        discard;
    }

    // Compute normal (points toward increasing alpha = inward)
    vec2 normal = normalize(grad);

    // Compute tangent along edge
    vec2 tangent = vec2(-normal.y, normal.x);

    // Compute projection along tangent using screen-space coordinates
    vec2 pos = gl_FragCoord.xy; // pixel coords
    // We want: tile repeats every u_borderWidth pixels along the tangent projection.
    float proj = dot(pos, tangent);
    // Convert to [0,1] for texture: fract(proj / u_borderWidth)
    float u = fract(proj / u_borderWidth);

    // v coordinate: map dist∈[0,u_thickness] → [0,1]
    float v = dist / u_thickness;

    // Sample border sprite
    vec4 col = texture2D(u_border, vec2(u, v));
    // Optionally: col *= u_tint;
    gl_FragColor = col;
}