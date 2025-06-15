//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
//varying vec4 v_vColour;
uniform sampler2D u_mask;      // the mask surface texture
uniform vec4 u_bgcolor;        // background RGBA color

void main()
{
	float m = texture2D(u_mask, v_vTexcoord).a;
    if (m < 0.5) {
        discard;
    }
	gl_FragColor = u_bgcolor;
    //gl_FragColor = v_vColour * texture2D( gm_BaseTexture, v_vTexcoord );
}
