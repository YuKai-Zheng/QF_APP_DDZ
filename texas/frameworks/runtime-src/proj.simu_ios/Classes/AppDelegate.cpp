#include <fstream>
#include "AppDelegate.h"
#include "CCLuaEngine.h"
#include "SimpleAudioEngine.h"
#include "cocos2d.h"
#include "Runtime.h"
#include "ConfigParser.h"

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
    director->setAnimationInterval(1.0 / 60);
   
    auto engine = LuaEngine::getInstance();
    ScriptEngineManager::getInstance()->setScriptEngine(engine);

    LuaStack* stack = engine->getLuaStack();
#if 0   //(CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    std::string tea_key = QNative::shareInstance()->getTeaKey();
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
	stack->addSearchPath("src/cocos"); // 添加cocos代码搜索路径

	stack->addSearchPath( (QNative::shareInstance()->getUpdatePath()).c_str() ); // first find lua file by updateFile
	


// ADD-END

	// 启动心跳
	std::thread* hbThread = new std::thread(&AppDelegate::heartbeat,this);
	// 脱离
	hbThread->detach();


    // 防止某些情况下获取环境变量有问题
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
    //在lua代码的 GlobalController:processAudioPauseToBg 中统一处理切入后台的音效
    //SimpleAudioEngine::getInstance()->pauseBackgroundMusic();
	QNative::shareInstance()->applicationActions("hide");
}

// this function will be called when the app is active again
void AppDelegate::applicationWillEnterForeground()
{
    Director::getInstance()->startAnimation();
    //在lua代码的 GlobalController:processAudioResumeFromBg 中统一处理后台返回的音效
    //SimpleAudioEngine::getInstance()->resumeBackgroundMusic();
    QNative::shareInstance()->applicationActions("show");
}

void AppDelegate::heartbeat() {
    while(1) {
        // 必须已经连接的状态，才发送心跳
        if (ferry::ScriptFerry::getInstance()->isConnected()) {
            netkit::Box* box = new netkit::Box();
            box->cmd = 7;

            time_t lastHeartbeatSendTime = time(NULL);
            ferry::ScriptFerry::getInstance()->send(box);

            // 等几秒，看服务器是否有响应，如果没有，就说明超时
            MY_SLEEP(9);

            time_t lastActiveTime = ferry::ScriptFerry::getInstance()->getLastActiveTime();

            // 一定要是<不是<=，因为速度很快的话，秒级是一样大的
            if (lastActiveTime < lastHeartbeatSendTime) {
                // 说明在send之后没有收到任何服务器消息
                cocos2d::log("connection active timeout. lastActiveTime: %u, lastHeartbeatSendTime: %u", 
                             lastActiveTime, lastHeartbeatSendTime);
                ferry::ScriptFerry::getInstance()->disconnect();
            }
        }

        // 休息几秒
        MY_SLEEP(1);
    }
}
