/******************************************************
 * Program Assignment:  着色器接口封装
 * Author:              Lynn
 * Date:                2015/2/20  22:20
 * Description:         简化外部对于shaders的调用逻辑
 *****************************************************/

#ifndef __SHADER_BOX_H__
#define __SHADER_BOX_H__


#include "SpriteBlur.h"

namespace shader {
    
    class ShaderBox
    {
    public:
        static ShaderBox* getInstance();

        // 异步抓屏并进行高斯模糊处理
        void getScreenBlurSprite(const std::function<void(bool, cocos2d::Sprite* sprite)>& afterCaptured, bool quarter, unsigned int radius);
        
        // 异步抓屏并进行灰度化处理
        void getScreenGraySprite(const std::function<void(bool, cocos2d::Sprite* sprite)>& afterCaptured, bool quarter);
        
        // 异步抓屏并进行高亮处理
        void getScreenHighlightSprite(const std::function<void(bool, cocos2d::Sprite* sprite)>& afterCaptured, bool quarter, unsigned int increment);
        
    private:
        ShaderBox();
        ~ShaderBox();
    };
}

#endif /* __SHADER_BOX_H__ */
