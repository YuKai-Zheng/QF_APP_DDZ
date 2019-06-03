#include <fstream>
#include "AppDelegate.h"
#include "CCLuaEngine.h"
#include "SimpleAudioEngine.h"
#include "cocos2d.h"
#include "Runtime.h"
#include "ConfigParser.h"
#include "platform/CCFileUtils.h"

#include "script_ferry/lua_ferry_auto.hpp"
#include "script_ferry/lua_ferry_manual.hpp"
#include "luapb/LuaPB.h"
#include "qf/qf_auto_bindings.hpp"

#include "webview/ZYWebView.h"
#include "qf/QNative.h"
#include "script_ferry/ScriptFerry.h"
#include "netkit/Box.h"
#include "lfs/lfs.h"
#include <thread>

#if defined(_WIN32) || (defined(CC_TARGET_PLATFORM) && CC_TARGET_PLATFORM==CC_PLATFORM_WIN32)
#include <winsock2.h>
#pragma comment(lib,"pthreadVSE2.lib")
#define MY_SLEEP(sec) Sleep((sec)*1000);

#else
#include <unistd.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#define MY_SLEEP(sec) sleep(sec);
#endif


using namespace CocosDenshion;

USING_NS_CC;
using namespace std;

AppDelegate::AppDelegate()
{
}

AppDelegate::~AppDelegate()
{
    SimpleAudioEngine::end();
}

bool AppDelegate::applicationDidFinishLaunching()
{
    
#if (COCOS2D_DEBUG>0)
    initRuntime();
#endif
    
    if (!ConfigParser::getInstance()->isInit()) {
            ConfigParser::getInstance()->readConfig();
        }

    // initialize director
    auto director = Director::getInstance();
    auto glview = director->getOpenGLView();    
    if(!glview) {
        Size viewSize = ConfigParser::getInstance()->getInitViewSize();
        string title = ConfigParser::getInstance()->getInitViewName();
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 || CC_TARGET_PLATFORM == CC_PLATFORM_MAC)
        extern void createSimulator(const char* viewName, float width, float height,bool isLandscape = true, float frameZoomFactor = 1.0f);
        bool isLanscape = ConfigParser::getInstance()->isLanscape();
        createSimulator(title.c_str(),viewSize.width,viewSize.height,isLanscape);
#else
        glview = GLView::createWithRect(title.c_str(), Rect(0,0,viewSize.width,viewSize.height));
        director->setOpenGLView(glview);
#endif
    }

   
    // set FPS. the default value is 1.0/60 if you don't call this
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    director->setAnimationInterval(1.0 / 45);
#else
    director->setAnimationInterval(1.0 / 60);
#endif
   
    auto engine = LuaEngine::getInstance();
    ScriptEngineManager::getInstance()->setScriptEngine(engine);

    LuaStack* stack = engine->getLuaStack();
    std::string channel_name = QNative::shareInstance()->zny_getChannelName();
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    std::string tea_key = channel_name + QNative::shareInstance()->zny_getTeaKey();
    std::string tea_begin = "qfkey";
    stack->setXXTEAKeyAndSign(tea_key.c_str(), tea_key.size(), tea_begin.c_str(), tea_begin.size());
#endif

    //register custom function
	register_all_qf_auto_bindings(stack->getLuaState());
    
// ADD-BEGIN by dantezhu in 2014-10-24 17:02:48
    lua_getglobal(stack->getLuaState(), "_G");
    register_all_ferry(stack->getLuaState());
    register_all_ferry_manual(stack->getLuaState());

    luaopen_luapb(stack->getLuaState());
	luaopen_lfs(stack->getLuaState());

    lua_settop(stack->getLuaState(), 0);
	stack->addSearchPath("src/cocos"); // Ìí¼Ócocos´úÂëËÑË÷Â·¾¶
    
	stack->addSearchPath( (QNative::shareInstance()->zny_getUpdatePath()).c_str() ); // first find lua file by updateFile
    
// ADD-END
    
    // ÉèÖÃ×ÊÔ´¼ÓÃÜµÄkeyºÍsign
    FileUtils::getInstance()->setResourceEncryptKeyAndSign(channel_name, "XXTEA");
    
	// Æô¶¯ÐÄÌø
	std::thread* hbThread = new std::thread(&AppDelegate::heartbeat,this);
	// ÍÑÀë
	hbThread->detach();


    // ·ÀÖ¹Ä³Ð©Çé¿öÏÂ»ñÈ¡»·¾³±äÁ¿ÓÐÎÊÌâ
    #if (COCOS2D_DEBUG>0) && (defined(CC_TARGET_PLATFORM) && CC_TARGET_PLATFORM==CC_PLATFORM_WIN32)
        if (startRuntime())
            return true;
    #endif

    engine->executeScriptFile(ConfigParser::getInstance()->getEntryFile().c_str());
    
    cocos2d::log(" -- applicationDidFinishLaunching -- ");
    return true;
}

// This function will be called when the app is inactive. When comes a phone call,it's be invoked too
void AppDelegate::applicationDidEnterBackground()
{
    Director::getInstance()->stopAnimation();
    //ÔÚlua´úÂëµÄ GlobalController:processAudioPauseToBg ÖÐÍ³Ò»´¦ÀíÇÐÈëºóÌ¨µÄÒôÐ§
    //SimpleAudioEngine::getInstance()->pauseBackgroundMusic();
	QNative::shareInstance()->zny_applicationActions("hide");
}

// this function will be called when the app is active again
void AppDelegate::applicationWillEnterForeground()
{
    Director::getInstance()->startAnimation();
    //ÔÚlua´úÂëµÄ GlobalController:processAudioResumeFromBg ÖÐÍ³Ò»´¦ÀíºóÌ¨·µ»ØµÄÒôÐ§
    //SimpleAudioEngine::getInstance()->resumeBackgroundMusic();
    QNative::shareInstance()->zny_applicationActions("show");
}

void AppDelegate::heartbeat() {
    while(1) {
        // ±ØÐëÒÑ¾­Á¬½ÓµÄ×´Ì¬£¬²Å·¢ËÍÐÄÌø
        if (ferry::ScriptFerry::getInstance()->isConnected()) {
            netkit::Box* box = new netkit::Box();
            box->cmd = 7;

            time_t lastHeartbeatSendTime = time(NULL);
            ferry::ScriptFerry::getInstance()->send(box);

            // µÈ¼¸Ãë£¬¿´·þÎñÆ÷ÊÇ·ñÓÐÏìÓ¦£¬Èç¹ûÃ»ÓÐ£¬¾ÍËµÃ÷³¬Ê±
            MY_SLEEP(9);

            time_t lastActiveTime = ferry::ScriptFerry::getInstance()->getLastActiveTime();

            // Ò»¶¨ÒªÊÇ<²»ÊÇ<=£¬ÒòÎªËÙ¶ÈºÜ¿ìµÄ»°£¬Ãë¼¶ÊÇÒ»Ñù´óµÄ
            if (lastActiveTime < lastHeartbeatSendTime) {
                // ËµÃ÷ÔÚsendÖ®ºóÃ»ÓÐÊÕµ½ÈÎºÎ·þÎñÆ÷ÏûÏ¢
                cocos2d::log("connection active timeout. lastActiveTime: %u, lastHeartbeatSendTime: %u", 
                             lastActiveTime, lastHeartbeatSendTime);
                ferry::ScriptFerry::getInstance()->disconnect();
            }
        }

        // ÐÝÏ¢¼¸Ãë
        MY_SLEEP(1);
    }
}
