/******************************************************
 * Program Assignment:  高斯模糊精灵
 * Author:              Lynn
 * Date:                2015/2/19  18:20
 * Description:         继承自Sprite, 重写initWithTexture,
                        使用OpenGL接口渲染,为纹理添加滤镜效果
 *****************************************************/

#ifndef __SPRITE_BLUR_H__
#define __SPRITE_BLUR_H__

#include <cocos2d.h>
//#include <cocos-ext.h>

namespace shader {
    namespace blur {

        class SpriteBlur : public cocos2d::Sprite
        {
        public:
            ~SpriteBlur();
            //从图像文件创建一个高斯模糊效果精灵
            static SpriteBlur* create(const char *pszFileName);
            //从图像纹理创建一个高斯模糊效果精灵
            static SpriteBlur* createWithTexture(cocos2d::Texture2D* texture);
            void setBlurRadius(float radius);
            void setBlurSampleNum(float num);

        protected:
            float _blurRadius;
            float _blurSampleNum;
            bool initWithTexture(cocos2d::Texture2D* texture, const cocos2d::Rect&  rect);
            void initGLProgram();
        };
    }
}


#endif /* __SPRITE_BLUR_H__ */
