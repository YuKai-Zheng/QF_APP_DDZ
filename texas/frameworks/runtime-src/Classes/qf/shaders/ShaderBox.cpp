/******************************************************
 * Program Assignment:  着色器接口封装
 * Author:              Lynn
 * Date:                2015/2/20  22:20
 * Description:         简化外部对于shaders的调用逻辑
 *****************************************************/

#include "ShaderBox.h"
#include "ScreenCaptureUtil.h"

namespace shader {
    
static ShaderBox* s_shaderbox = NULL;

ShaderBox::ShaderBox()
{}

ShaderBox::~ShaderBox()
{}

ShaderBox* ShaderBox::getInstance()
{
    if (s_shaderbox == NULL)
    {
        s_shaderbox = new ShaderBox();
    }
    return s_shaderbox;
}

void ShaderBox::getScreenBlurSprite(const std::function<void(bool, cocos2d::Sprite* sprite)>& afterCaptured, bool quarter, unsigned int radius, int arg)
{
    /*
        高斯模糊实现上，有两种选择，一种采用StackBlur查表算法，一种采用OpenGL滤镜方式。
        前者性能较优，后者效果较优。目前采用前者。
     */
    shader::captureScreenToSpriteWithBlur(afterCaptured, quarter, radius);
}

void ShaderBox::getScreenGraySprite(const std::function<void(bool, cocos2d::Sprite* sprite)>& afterCaptured, bool quarter, int arg)
{
    shader::captureScreenToSpriteWithGrey(afterCaptured, quarter);
}

void ShaderBox::getScreenHighlightSprite(const std::function<void(bool, cocos2d::Sprite* sprite)>& afterCaptured, bool quarter, unsigned int increment, int arg)
{
    shader::captureScreenToSpriteWithHighlight(afterCaptured, quarter, increment);
}


}
