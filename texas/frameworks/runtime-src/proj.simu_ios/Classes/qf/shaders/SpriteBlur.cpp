/******************************************************
 * Program Assignment:  高斯模糊精灵
 * Author:              Lynn
 * Date:                2015/2/19  18:20
 * Description:         继承自Sprite, 重写initWithTexture,
                        使用OpenGL接口渲染,为纹理添加滤镜效果
 *****************************************************/

#include "SpriteBlur.h"

namespace shader {
namespace blur {
SpriteBlur::~SpriteBlur()
{
    _blurRadius = 6.4;
    _blurSampleNum = 3.6;
}

SpriteBlur* SpriteBlur::create(const char *pszFileName)
{
    SpriteBlur* pRet = new SpriteBlur();
    if (pRet && pRet->initWithFile(pszFileName))
    {
        pRet->autorelease();
    }
    else
    {
        CC_SAFE_DELETE(pRet);
    }
    
    return pRet;
}

SpriteBlur* SpriteBlur::createWithTexture(cocos2d::Texture2D *pTexture)
{
    CCAssert(pTexture != NULL, "Invalid texture for sprite");
    
    cocos2d::Rect rect = cocos2d::Rect::ZERO;
    rect.size = pTexture->getContentSize();
    
    SpriteBlur* pRet = new SpriteBlur();
    if (pRet && pRet->initWithTexture(pTexture,rect))
    {
        pRet->autorelease();
    }
    else
    {
        CC_SAFE_DELETE(pRet);
    }
    
    return pRet;
}

bool SpriteBlur::initWithTexture(cocos2d::Texture2D* texture, const cocos2d::Rect& rect)
{
    if( Sprite::initWithTexture(texture, rect) )
    {
#if CC_ENABLE_CACHE_TEXTURE_DATA
        auto listener = cocos2d::EventListenerCustom::create(EVENT_RENDERER_RECREATED, [this](cocos2d::EventCustom* event){
            setGLProgram(nullptr);
            initGLProgram();
        });
        
        _eventDispatcher->addEventListenerWithSceneGraphPriority(listener, this);
#endif
        
        initGLProgram();
        
        return true;
    }
    
    return false;
}

void SpriteBlur::initGLProgram()
{
    GLchar * fragSource = (GLchar*) cocos2d::String::createWithContentsOfFile(
                                                                     cocos2d::FileUtils::getInstance()->fullPathForFilename("opengl/blur.fsh").c_str())->getCString();
    auto program = cocos2d::GLProgram::createWithByteArrays(cocos2d::ccPositionTextureColor_noMVP_vert, fragSource);
    
    auto glProgramState = cocos2d::GLProgramState::getOrCreateWithGLProgram(program);
    setGLProgramState(glProgramState);
    
    auto size = getTexture()->getContentSizeInPixels();
    getGLProgramState()->setUniformVec2("resolution", size);
    getGLProgramState()->setUniformFloat("blurRadius", _blurRadius);
    getGLProgramState()->setUniformFloat("sampleNum", _blurSampleNum);
}

void SpriteBlur::setBlurRadius(float radius)
{
    if (_blurRadius != radius)
    {
        _blurRadius = radius;
        getGLProgramState()->setUniformFloat("blurRadius", _blurRadius);
    }
}

void SpriteBlur::setBlurSampleNum(float num)
{
    if (_blurSampleNum != num)
    {
        _blurSampleNum = num;
        getGLProgramState()->setUniformFloat("sampleNum", _blurSampleNum);
    }
}
}
}