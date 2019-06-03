#include <sstream>
#include "QNative.h"
#include "QUtil.h"
#include "CCLuaValue.h"

#include "CCLuaEngine.h"
#include "CCLuaBridge.h"

#include "qf/crypto/md5/md5.h"
#include "shaders/ShaderBox.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include "jni/JniHelper.h"
#endif

using namespace std;
using namespace cocos2d;



const string JAVA_CLASS_NAME = "com/qufan/texas/util/Util";
const string UPDATE = "update";
const string CACHE  = "cache";

QNative * __QNative_instance = nullptr;



QNative * QNative::shareInstance() {
	if (__QNative_instance == nullptr ) {
		__QNative_instance = new QNative();
		__QNative_instance->init();
	}

	return __QNative_instance;
}


void QNative::init() {
    // bugfix. 为了解决热更新之后，升级大版本会优先使用热更新下来的代码的问题
    // update, cache 目录，要添加上 channel和 version。
    // 之所有要有channel，是因为android有不同渠道，代码不同的问题
    
    std::string strChannel = "UNKNOWN";
    std::string strVersion = "UNKNOWN";
    
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    NSString * channel = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"Channel"];
    NSString * version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    strChannel = [channel UTF8String];
    strVersion = [version UTF8String];
#endif

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)

    JniMethodInfo methodVersion;
    if (JniHelper::getStaticMethodInfo(methodVersion, JAVA_CLASS_NAME.c_str(), "getVersionCode", "()I")) {
        jint version = methodVersion.env->CallStaticIntMethod(methodVersion.classID, methodVersion.methodID);
        std::stringstream ss;
        ss << version;
        strVersion = ss.str();
        methodVersion.env->DeleteLocalRef(methodVersion.classID);
    }

    JniMethodInfo methodChannel;

    if (JniHelper::getStaticMethodInfo(methodChannel, JAVA_CLASS_NAME.c_str(), "getChannel", "()Ljava/lang/String;")) {
        jstring str = (jstring)methodChannel.env->CallStaticObjectMethod(methodChannel.classID, methodChannel.methodID);
        strChannel = JniHelper::jstring2string(str);

        methodChannel.env->DeleteLocalRef(methodChannel.classID);
        methodChannel.env->DeleteLocalRef(str);
    }
#endif
    
    _updatePath = CCFileUtils::getInstance()->getWritablePath()  + UPDATE + "_" + strChannel + "_" +strVersion;
    
    CCLOG("updatePath: %s", _updatePath.c_str());
    
    _cachePath = CCFileUtils::getInstance()->getWritablePath()  + CACHE;
	
	QUtil::mkdir(_updatePath.c_str());
	QUtil::mkdir(_cachePath.c_str());
	
	_luaApplicationActionsHandle = -1;

	

}
std::string QNative::getKey()  {
    return "EFyhU+#^$gCoR4knZPJ_A26tDwXO)BVd";
}

std::string QNative::getTeaKey () {
    return "\xe7\x43\xa2\xb4\x67\x12\xc8\x3f\xaa\x8a\xca\x4f\x20\x62\xe5\x03\x9d\x88\xc0\x73\x34\x3a\xcd\x8d\xbf\x86\xf1\x5b\xdf\x44\x97\x2b";
}

std::string QNative::md5(const char * str) {
	MD5 md5;
	md5.update(str);
	return md5.toString();
}

std::string QNative::md5WithBase64(const std::string &str){
	size_t len = (size_t)str.length()/2;
	cocos2d::log("[cpp] md5WithBase64 --- length = %d",len);

	unsigned char * conntent = new unsigned char[len];
	for (size_t i = 0 ; i < str.length() ; i += 2)
	{
		conntent[i/2] = QUtil::getCharFromHex(str[i],str[i+1]);
	}
	MD5 md5;
	md5.update((const void *)conntent,len);
	return md5.toString();
}

void QNative::setLuaApplicationHanlder(int luacb) {
	_luaApplicationActionsHandle = luacb;
}

string QNative::getUpdatePath(){
	return _updatePath;
}

string QNative::getCachePath(){
	return _cachePath;
}

void QNative::mkdir(const char * path){
	QUtil::mkdir(path);
}
void QNative::rmdir(const char * path){
	QUtil::rmdir(path);
}


Sprite * QNative::getCirleImg (const char * mask , const char * file){
	Sprite * sa = Sprite::create(mask);
    Sprite * sb = Sprite::create(file);
    
    if(sa == NULL || sb == NULL){
        return NULL;
    }
    
    float w1 = sa->getContentSize().width;
    float h1 = sa->getContentSize().height;
    float w2 = sb->getContentSize().width;
    float h2 = sb->getContentSize().height;
    float scale = 1.0f;
    if (w2 > h2) {
        scale = h1 / h2;
    }
    else {
        scale = w1 / w2;
    }
	sb->setScale(scale);
	sa->setPosition(w1/2,h1/2);
	sb->setPosition(w1/2,h1/2);
	sb->setFlippedY(true);
	RenderTexture * rt = RenderTexture::create(w1, h1);
	BlendFunc blendFunc;
	blendFunc.src = GL_DST_ALPHA;
	blendFunc.dst = GL_ZERO; 
	sb->setBlendFunc(blendFunc);
	rt->begin();
	sa->visit();
	sb->visit();
	rt->end();
	return Sprite::createWithTexture(rt->getSprite()->getTexture());
}

string QNative::getName() {
	return "QNative";
}


void QNative::applicationActions(const char * type) {

	cocos2d::log(" -- applicationActions -- %s",type);
	cocos2d::LuaStack * stack =  cocos2d::LuaEngine::getInstance()->getLuaStack();
	stack->pushString(type);
	stack->executeFunctionByHandler(_luaApplicationActionsHandle,1);
}

void QNative::getScreenBlurSprite(const std::function<void(bool, cocos2d::Sprite* sprite)>& afterCaptured, bool quarter, unsigned int radius)
{
    shader::ShaderBox::getInstance()->getScreenBlurSprite(afterCaptured, quarter, radius);
}

void QNative::getScreenGraySprite(const std::function<void(bool, cocos2d::Sprite* sprite)>& afterCaptured, bool quarter)
{
    shader::ShaderBox::getInstance()->getScreenGraySprite(afterCaptured, quarter);
}
void QNative::getScreenHighlightSprite(const std::function<void(bool, cocos2d::Sprite* sprite)>& afterCaptured, bool quarter, unsigned int increment)
{
    shader::ShaderBox::getInstance()->getScreenHighlightSprite(afterCaptured, quarter, increment);
}