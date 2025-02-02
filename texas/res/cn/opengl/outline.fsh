varying vec4 v_fragmentColor; // vertex shader传入，setColor设置的颜色
varying vec2 v_texCoord; // 纹理坐标
uniform float outlineSize; // 描边宽度，以像素为单位
uniform vec3 outlineColor; // 描边颜色
uniform vec2 textureSize; // 纹理大小（宽和高），为了计算周围各点的纹理坐标，必须传入它，因为纹理坐标范围是0~1
uniform vec3 foregroundColor; // 主要用于字体，可传可不传，不传默认为白色
uniform float outlineAlpha;
// 判断在这个角度上距离为outlineSize那一点是不是透明
int getIsStrokeWithAngel(float angel)
{
	int stroke = 0;
	float rad = angel * 0.01745329252; // 这个浮点数是 pi / 180，角度转弧度
	float a = texture2D(CC_Texture0, vec2(v_texCoord.x + outlineSize * cos(rad) / textureSize.x, v_texCoord.y + outlineSize * sin(rad) / textureSize.y)).a; // 这句比较难懂，outlineSize * cos(rad)可以理解为在x轴上投影，除以textureSize.x是因为texture2D接收的是一个0~1的纹理坐标，而不是像素坐标
	if (a >= 0.5)// 我把alpha值大于0.5都视为不透明，小于0.5都视为透明
	{
		stroke = 1;
	}
	return stroke;
}

void main()
{
	vec4 myC = texture2D(CC_Texture0, vec2(v_texCoord.x, v_texCoord.y)); // 正在处理的这个像素点的颜色
	myC.rgb *= foregroundColor;
	if (myC.a >= 0.5) // 不透明，不管，直接返回
	{
		gl_FragColor = v_fragmentColor * myC;
		return;
	}
	// 这里肯定有朋友会问，一个for循环就搞定啦，怎么这么麻烦！其实我一开始也是用for的，但后来在安卓某些机型（如小米4）会直接崩溃，查找资料发现OpenGL es并不是很支持循环，while和for都不要用
	int strokeCount = 0;
	strokeCount += getIsStrokeWithAngel(0.0);
	strokeCount += getIsStrokeWithAngel(30.0);
	strokeCount += getIsStrokeWithAngel(60.0);
	strokeCount += getIsStrokeWithAngel(90.0);
	strokeCount += getIsStrokeWithAngel(120.0);
	strokeCount += getIsStrokeWithAngel(150.0);
	strokeCount += getIsStrokeWithAngel(180.0);
	strokeCount += getIsStrokeWithAngel(210.0);
	strokeCount += getIsStrokeWithAngel(240.0);
	strokeCount += getIsStrokeWithAngel(270.0);
	strokeCount += getIsStrokeWithAngel(300.0);
	strokeCount += getIsStrokeWithAngel(330.0);

	if (strokeCount > 0) // 四周围至少有一个点是不透明的，这个点要设成描边颜色
	{
		myC.rgb = outlineColor;
		myC.a = outlineAlpha;
	}

	gl_FragColor = v_fragmentColor * myC;
}

  