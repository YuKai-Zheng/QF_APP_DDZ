#ifdef GL_ES

precision mediump float;

#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;


void main(void)

{

    vec4 c = texture2D(CC_Texture0, v_texCoord);
    vec4 final = c;
    final.r = (c.r + c.g + c.b) * 0.3333;

    final.g = (c.r + c.g + c.b) * 0.3333;

    final.b = (c.r + c.g + c.b) * 0.3333;

    gl_FragColor = final;

}