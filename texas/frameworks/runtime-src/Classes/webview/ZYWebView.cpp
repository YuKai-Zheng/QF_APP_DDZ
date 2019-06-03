//
//  ZYWebView.cpp
//  HelloWorld
//
//  Created by VincentChou on 14-8-6.
//
//

#include "ZYWebView.h"
#include "cocos2d.h"

using namespace cocos2d;


static ZYWebView * ____ZYWebViewInstances = NULL;

ZYWebView * ZYWebView::getInstance() {
    if (____ZYWebViewInstances == NULL) {
        ____ZYWebViewInstances = new ZYWebView();
        ____ZYWebViewInstances->init();
    }
    
    return ____ZYWebViewInstances;
}

ZYWebView::ZYWebView()
{
    
}

bool ZYWebView::init()
{
	return true;
}

void ZYWebView::showWebView(const char* url, float x, float y, float width, float height , int cb , int cb2)
{
    
    
    auto glview = Director::getInstance()->getOpenGLView();
    
    Size designsize = glview->getDesignResolutionSize();
    Size framesize = glview->getFrameSize();
    float sx = glview->getScaleX();
    float sy = glview->getScaleY();
    Size designframe(framesize.width / sx, framesize.height / sy);
    
    // 这里可能需要根据ResolutionPolicy进行修改。
    // Modify this ratio equation depend on your ResolutionPolicy.
    float ratio = designsize.height / framesize.height;
    
    Point orig((designframe.width - designsize.width) / 2, (designframe.height - designsize.height) / 2);
    
    x = x / ratio + orig.x / ratio; y = y / ratio + orig.y / ratio;
    width /= ratio; height /= ratio;
    
    _privateShowWebView(url, x, y, width, height,cb,cb2);
}

