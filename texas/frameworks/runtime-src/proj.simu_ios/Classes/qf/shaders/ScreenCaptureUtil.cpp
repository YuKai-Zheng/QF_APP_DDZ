/******************************************************
 * Program Assignment:  截屏并创建精灵
 * Author:              Lynn
 * Date:                2015/2/20  21:36
 * Description:         获取当前屏幕截图，并转化为Sprite，
                        (使用插值算法, 支持抓取缩略图)
 *****************************************************/

#include <stdlib.h>
#include "ScreenCaptureUtil.h"
#include "StackBlur.h"
#include "StackGrey.h"
#include "StackHighlight.h"

#define SHADER_SC_DEBUG 0

USING_NS_CC;

namespace shader
{

unsigned int s_sharder_type = SHADERTYPE_NONE;
unsigned int s_blur_radius = 2;
unsigned int s_hlight_increment = 50;

#if SHADER_SC_DEBUG > 0
long long _sc_start_time = 0;
long long getCurrentTime()
{
    struct timeval tv;
    gettimeofday(&tv, NULL);
    long long  time = ((long long)tv.tv_sec) * 1000 + tv.tv_usec / 1000;
    return time;
}
#endif

/**
 * 向图像源数据添加滤镜效果
 */
void addShaderToRaw(unsigned char* buffer, int width, int height)
{
    if (s_sharder_type == SHADERTYPE_BLUR)
    {
        std::shared_ptr<GLubyte> src(new GLubyte[width * height * 4], [](GLubyte* p){ CC_SAFE_DELETE_ARRAY(p); });
        memcpy(src.get(), buffer, width * height * 4);
        
        blur::doStackblur(buffer, width, height, s_blur_radius, src.get());
    }
    else if (s_sharder_type == SHADERTYPE_GREY)
    {
        grey::doStackGrey(buffer, width, height);
    }
    else if (s_sharder_type == SHADERTYPE_HLIGHT)
    {
        highlight::doStackHighlight(buffer, width, height, s_hlight_increment);
    }
}
    
/**
 * 开始截屏。一帧渲染完毕后被调用。
 */
void onCaptureScreen(const std::function<void(bool, Sprite* sprite)>& afterCaptured, bool quarter)
{
    auto glView = Director::getInstance()->getOpenGLView();
    auto frameSize = glView->getFrameSize();

#if (CC_TARGET_PLATFORM == CC_PLATFORM_MAC) || (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32) || (CC_TARGET_PLATFORM == CC_PLATFORM_LINUX)
    frameSize = frameSize * glView->getFrameZoomFactor() * glView->getRetinaFactor();
#endif
    
    int width = static_cast<int>(frameSize.width);
    int height = static_cast<int>(frameSize.height);
    
    bool succeed = false;
    
    Sprite* sprite = nullptr;
    Image* image = new Image();
    do
    {
        if (!image)
        {
            break;
        }
        
        std::shared_ptr<GLubyte> buffer(new GLubyte[width * height * 4], [](GLubyte* p){ CC_SAFE_DELETE_ARRAY(p); });
        if (!buffer)
        {
            break;
        }
#if SHADER_SC_DEBUG > 0
        cocos2d::log("图像处理开始: %lld ms", getCurrentTime() - _sc_start_time);
        _sc_start_time = getCurrentTime();
#endif
        /* 将图像数据从显存搬移到内存(gpu->cpu) */
        glPixelStorei(GL_PACK_ALIGNMENT, 1);
        glReadPixels(0, 0, width, height, GL_RGBA, GL_UNSIGNED_BYTE, buffer.get());
        
#if SHADER_SC_DEBUG > 0
        cocos2d::log("读取显存耗时: %lld ms", getCurrentTime() - _sc_start_time);
        _sc_start_time = getCurrentTime();
#endif
        if (quarter)
        {
            /* 图像数据插值缩放 */
            ssize_t flippedBufferSize = (width / 2) * (height / 2) * 4;
            std::shared_ptr<GLubyte> flippedBuffer(new GLubyte[flippedBufferSize], [](GLubyte* p) { CC_SAFE_DELETE_ARRAY(p); });
            if (!flippedBuffer)
            {
                break;
            }
            
            for (int row = 0; row < height; row+=2)
            {
                for (int column = 0; column < width; column+=2 )
                {
                    auto src_ptr = buffer.get() + row * width * 4 + column * 4;
                    auto dst_ptr = flippedBuffer.get() + (height / 2 - row / 2 - 1) * (width / 2) * 4 + column / 2 * 4;
                    memcpy(dst_ptr, src_ptr, 4);
                    dst_ptr -= 4;
                }
            }
            
#if SHADER_SC_DEBUG > 0
            cocos2d::log("插值缩放耗时: %lld ms", getCurrentTime() - _sc_start_time);
            _sc_start_time = getCurrentTime();
#endif
            /* 添加滤镜 */
            addShaderToRaw(flippedBuffer.get(), width / 2, height / 2);

#if SHADER_SC_DEBUG > 0
            cocos2d::log("添加滤镜耗时: %lld ms", getCurrentTime() - _sc_start_time);
            _sc_start_time = getCurrentTime();
#endif
            /* 源数据转换为图像 */
            image->initWithRawData(flippedBuffer.get(), flippedBufferSize, width / 2, height / 2, 8);
        }
        else
        {
            /* 图像数据反向读取 */
            std::shared_ptr<GLubyte> flippedBuffer(new GLubyte[width * height * 4], [](GLubyte* p) { CC_SAFE_DELETE_ARRAY(p); });
            if (!flippedBuffer)
            {
                break;
            }
            for (int row = 0; row < height; ++row)
            {
                memcpy(flippedBuffer.get() + (height - row - 1) * width * 4, buffer.get() + row * width * 4, width * 4);
            }
            
            /* 添加滤镜 */
            addShaderToRaw(flippedBuffer.get(), width, height);
            
            /* 源数据转换为图像 */
            image->initWithRawData(flippedBuffer.get(), width * height * 4, width, height, 8);
        }
        
        /* 图像源数据转化为纹理 */
        Texture2D* texture = new Texture2D();
        if( texture && texture->initWithImage(image))
        {
            /* 用纹理创建Sprite */
            sprite = Sprite::createWithTexture(texture);
            succeed = true;
        }
        else
        {
            break;
        }

#if SHADER_SC_DEBUG > 0
        cocos2d::log("图像处理结束: %lld ms", getCurrentTime() - _sc_start_time);
        //std::string fileName = cocos2d::FileUtils::getInstance()->getWritablePath() + "screen.jpg";
        //image->saveToFile(fileName);
        //cocos2d::log("截屏图片保存在: %s", fileName.c_str());
#endif
        
    }while(0);

    CC_SAFE_RELEASE(image);
    
    if (afterCaptured)
    {
        afterCaptured(succeed, sprite);
    }
}

/*
 * Capture screen interface
 */
void captureScreenToSprite(const std::function<void(bool, Sprite* sprite)>& afterCaptured, bool quarter)
{
#if SHADER_SC_DEBUG > 0
    const GLubyte* byteGlVersion = glGetString(GL_VERSION);
    cocos2d::log("OpenGL ES Version: %s", byteGlVersion);
    _sc_start_time = getCurrentTime();
#endif
    static CustomCommand captureScreenCommand;
    captureScreenCommand.init(std::numeric_limits<float>::max());
    captureScreenCommand.func = std::bind(onCaptureScreen, afterCaptured, quarter);
    Director::getInstance()->getRenderer()->addCommand(&captureScreenCommand);
}

void captureScreenToSpriteWithoutShader(const std::function<void(bool, Sprite* sprite)>& afterCaptured, bool quarter)
{
    s_sharder_type = SHADERTYPE_NONE;
    captureScreenToSprite(afterCaptured, quarter);
}
    
void captureScreenToSpriteWithBlur(const std::function<void(bool, cocos2d::Sprite* sprite)>& afterCaptured, bool quarter, unsigned int radius)
{
    s_sharder_type = SHADERTYPE_BLUR;
    s_blur_radius = radius;
    captureScreenToSprite(afterCaptured, quarter);
}

void captureScreenToSpriteWithGrey(const std::function<void(bool, cocos2d::Sprite* sprite)>& afterCaptured, bool quarter)
{
    s_sharder_type = SHADERTYPE_GREY;
    captureScreenToSprite(afterCaptured, quarter);
}

void captureScreenToSpriteWithHighlight(const std::function<void(bool, cocos2d::Sprite* sprite)>& afterCaptured, bool quarter, unsigned int increment)
{
    s_sharder_type = SHADERTYPE_HLIGHT;
    s_hlight_increment = increment;
    captureScreenToSprite(afterCaptured, quarter);
}

}
