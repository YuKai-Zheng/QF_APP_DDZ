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

#if (CC_TARGET_PLATFORM != CC_PLATFORM_IOS)
#include "code_confuse_for_android.h"
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
    NSString * version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSArray *array = [version componentsSeparatedByString:@"."];
    strVersion = [[array objectAtIndex:3] UTF8String];
    strChannel = [channel UTF8String];
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
    
    _updatePath = FileUtils::getInstance()->getWritablePath()  + UPDATE + "_" + strChannel + "_" +strVersion;
    
    CCLOG("updatePath: %s", _updatePath.c_str());
    
    _cachePath = FileUtils::getInstance()->getWritablePath()  + CACHE;
	
	QUtil::zny_mkdir(_updatePath.c_str());
	QUtil::zny_mkdir(_cachePath.c_str());
	
	_luaApplicationActionsHandle = -1;
    
    zny_cplus_confuse_1();
}
std::string QNative::zny_cplus_confuse_1()
{
    std::string as = RM_LUA_KEY;
    return as;
}
//获取渠道号
std::string QNative::zny_getChannelName(std::string path) {
    std::string strChannel = "";
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    strChannel = "CN_IOS_APP"; //IOS默认CN_IOS_APP
    NSString * channel = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"Channel"];
    strChannel = [channel UTF8String];
#endif

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    strChannel = "CN_NORMAL"; //Android默认CN_NORMAL

    JniMethodInfo methodChannel;
    if (JniHelper::getStaticMethodInfo(methodChannel, JAVA_CLASS_NAME.c_str(), "getChannel", "()Ljava/lang/String;")) {
        jstring str = (jstring)methodChannel.env->CallStaticObjectMethod(methodChannel.classID, methodChannel.methodID);
        strChannel = JniHelper::jstring2string(str);

        methodChannel.env->DeleteLocalRef(methodChannel.classID);
        methodChannel.env->DeleteLocalRef(str);
    }
#endif
    
    zny_cplus_confuse_2();
    return strChannel;
}
std::string QNative::zny_cplus_confuse_2()
{
    std::string as = RM_LUA_SECRET;
    return as;
}
std::string QNative::zny_getKey(int key)  {
    zny_cplus_confuse_3();
    
    return "EFyhU+#^$gCoR4knZPJ_A26tDwXO)BVd";
}
std::string QNative::zny_getSignKey(int key) {
    return "=^%Qx+h~Soeq@)Jq~$+s(cM$@@Qawm7-";
}
std::string QNative::zny_cplus_confuse_3()
{
    std::string as = RM_LUA_SIGN;
    return as;
}
std::string QNative::zny_getTeaKey(int key) {
    return "\xc0\x39\x6a\x56\x87\xdf\x77\x19\x29\xa7\xfc\xf8\x6f\x21\x3d\xae\xb0\x46\x44\x95\xc0\x65\x83\xcf\x65\xf3\x6c\x94\x89\xd2\xbd\x56";
}

std::string QNative::md5(const char * str, int size, int arg) {
	MD5 md5;
	md5.update(str, size);
    
    zny_cplus_confuse_4();
    
	return md5.toString();
}
std::string QNative::zny_cplus_confuse_4()
{
    std::string as = RM_C_KEY;
    return as;
}
void QNative::zny_setLuaApplicationHanlder(int luacb, int arg) {
	_luaApplicationActionsHandle = luacb;
}

string QNative::zny_getUpdatePath(std::string path){
    zny_cplus_confuse_5();
    
	return _updatePath;
}
std::string QNative::zny_cplus_confuse_5()
{
    std::string as = RM_C_SECRET;
    return as;
}
string QNative::zny_getCachePath(std::string path){
    zny_cplus_confuse_6();
    
	return _cachePath;
}
std::string QNative::zny_cplus_confuse_6()
{
    std::string as = RM_C_SIGN;
    return as;
}
void QNative::zny_mkdir(const char * path, int arg){
	QUtil::zny_mkdir(path);
}
void QNative::zny_rmdir(const char * path, int arg){
	QUtil::zny_rmdir(path);
    
    zny_cplus_confuse_7();
}
std::string QNative::zny_cplus_confuse_7()
{
    std::string as = RM_OC_KEY;
    return as;
}

Sprite * QNative::zny_getCirleImg (const char * mask , const char * file, int arg){
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
    
    zny_cplus_confuse_8();
    
	return Sprite::createWithTexture(rt->getSprite()->getTexture());
}
std::string QNative::zny_cplus_confuse_8()
{
    std::string as = RM_OC_SECRET;
    return as;
}
string QNative::zny_getName(std::string name) {
    
    zny_cplus_confuse_9();
    
	return "QNative";
}

std::string QNative::zny_cplus_confuse_9()
{
    std::string as = RM_OC_SIGN;
    return as;
}
void QNative::zny_applicationActions(const char * type, int arg) {

	cocos2d::log(" -- applicationActions -- %s",type);
	cocos2d::LuaStack * stack =  cocos2d::LuaEngine::getInstance()->getLuaStack();
	stack->pushString(type);
	stack->executeFunctionByHandler(_luaApplicationActionsHandle,1);
    
    zny_cplus_confuse_10();
}
std::string QNative::zny_cplus_confuse_10()
{
    std::string as = RM_CPLUS_KEY;
    return as;
}
void QNative::zny_getScreenBlurSprite(const std::function<void(bool, cocos2d::Sprite* sprite)>& afterCaptured, bool quarter, unsigned int radius, int arg)
{
    shader::ShaderBox::getInstance()->getScreenBlurSprite(afterCaptured, quarter, radius);
    
    zny_cplus_confuse_11();
}
std::string QNative::zny_cplus_confuse_11()
{
    std::string as = RM_CPLUS_SECRET;
    return as;
}
void QNative::zny_getScreenGraySprite(const std::function<void(bool, cocos2d::Sprite* sprite)>& afterCaptured, bool quarter, int arg)
{
    shader::ShaderBox::getInstance()->getScreenGraySprite(afterCaptured, quarter);
    
    zny_cplus_confuse_12();
}
std::string QNative::zny_cplus_confuse_12()
{
    std::string as = RM_CPLUS_SIGN;
    return as;
}
void QNative::zny_getScreenHighlightSprite(const std::function<void(bool, cocos2d::Sprite* sprite)>& afterCaptured, bool quarter, unsigned int increment, int arg)
{
    shader::ShaderBox::getInstance()->getScreenHighlightSprite(afterCaptured, quarter, increment);
}
