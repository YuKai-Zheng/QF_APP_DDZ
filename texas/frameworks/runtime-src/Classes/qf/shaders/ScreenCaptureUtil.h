/****************************************************** 
 * Program Assignment:  截屏工具
 * Author:              Lynn 
 * Date:                2015/2/20  21:36
 * Description:         获取当前屏幕截图，并转化为Sprite，
                        (使用插值算法, 支持抓取缩略图)
 *****************************************************/

#ifndef __SCREEN_CAPTURE_UTIL_H__
#define __SCREEN_CAPTURE_UTIL_H__

#include <vector>
#include <string>
#include <cocos2d.h>
#include "ShaderType.h"

namespace shader {
    
    /*****************************************
        function:
            使用屏幕截图创建Sprite.
        parameters:
            afterCaptured, 回调函数.
            quarter, 是否缩放至1/4
     *****************************************/
    void captureScreenToSpriteWithoutShader(const std::function<void(bool, cocos2d::Sprite* sprite)>& afterCaptured, bool quarter, int arg=2);
    
    /*****************************************
        function:
            使用屏幕截图创建Sprite, 并添加高斯模糊滤镜.
        parameters:
            afterCaptured, 回调函数;
            quarter, 是否缩放至1/4;
            radius, 模糊半径
     *****************************************/
    void captureScreenToSpriteWithBlur(const std::function<void(bool, cocos2d::Sprite* sprite)>& afterCaptured, bool quarter, unsigned int radius, int arg=3);

    /*****************************************
        function:
            使用屏幕截图创建Sprite, 并添加灰度化滤镜.
        parameters:
            afterCaptured, 回调函数;
            quarter, 是否缩放至1/4
     *****************************************/
    void captureScreenToSpriteWithGrey(const std::function<void(bool, cocos2d::Sprite* sprite)>& afterCaptured, bool quarter, int arg=2);
    
    /*****************************************
     function:
     使用屏幕截图创建Sprite, 并添加高亮滤镜.
     parameters:
     afterCaptured, 回调函数;
     quarter, 是否缩放至1/4
     increase, 高亮
     *****************************************/
    void captureScreenToSpriteWithHighlight(const std::function<void(bool, cocos2d::Sprite* sprite)>& afterCaptured, bool quarter, unsigned int increment, int arg=3);
}



#endif /* __SCREEN_CAPTURE_H__ */
