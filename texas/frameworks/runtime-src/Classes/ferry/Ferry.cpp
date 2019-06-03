//
// Created by dantezhu on 14-10-22.
//

#include "Ferry.h"
#include "cocos2d.h"

namespace ferry {

static void _log(const char *format, va_list args)
{
    using namespace cocos2d;

    char buf[MAX_LOG_LENGTH] = "[ferry]";
    int length = strlen(buf);

    vsnprintf(buf+length, MAX_LOG_LENGTH-length-3, format, args);
    strcat(buf, "\n");

#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
    __android_log_print(ANDROID_LOG_DEBUG, "ferry", "%s", buf);

#elif CC_TARGET_PLATFORM ==  CC_PLATFORM_WIN32 || CC_TARGET_PLATFORM == CC_PLATFORM_WINRT || CC_TARGET_PLATFORM == CC_PLATFORM_WP8
    WCHAR wszBuf[MAX_LOG_LENGTH] = {0};
    MultiByteToWideChar(CP_UTF8, 0, buf, -1, wszBuf, sizeof(wszBuf));
    OutputDebugStringW(wszBuf);
    WideCharToMultiByte(CP_ACP, 0, wszBuf, -1, buf, sizeof(buf), nullptr, FALSE);
    fprintf(stdout, buf);
    fflush(stdout);
#else
    // Linux, Mac, iOS, etc
    fprintf(stdout, buf);
    fflush(stdout);
#endif

#if (CC_TARGET_PLATFORM != CC_PLATFORM_WINRT)
    Director::getInstance()->getConsole()->log(buf);
#endif

}

Ferry *Ferry::getInstance() {
    // 用指针可以保证进程结束时，释放晚一些，不会报错
    static Ferry *instance;
    if (!instance) {
        instance = new Ferry();
    }
    return instance;
}

Ferry::~Ferry() {
    stopSchedule();
}

int Ferry::start() {
    int ret;

    if (0 != (ret = BaseFerry::start())) {
        return ret;
    }

    startSchedule();

    return 0;
}

void Ferry::stop() {
    if (!isRunning()) {
        return;
    }

    stopSchedule();

    BaseFerry::stop();
}

void Ferry::pauseSchedule() {
    cocos2d::Director::getInstance()->getScheduler()->pauseTarget(this);
}

void Ferry::resumeSchedule() {
    cocos2d::Director::getInstance()->getScheduler()->resumeTarget(this);
}

bool Ferry::isSchedulePaused() {
    return cocos2d::Director::getInstance()->getScheduler()->isTargetPaused(this);
}

void Ferry::startSchedule() {
    auto func = [this](float dt){
        update();
    };

    // 先调用这个
    cocos2d::Director::getInstance()->getScheduler()->schedule(func, this, 0, false, __FUNCTION__);
}

void Ferry::stopSchedule() {
    cocos2d::Director::getInstance()->getScheduler()->unscheduleAllForTarget(this);
}

void Ferry::log(const char *format, ...) {
    va_list args;
    va_start(args, format);
    _log(format, args);
    va_end(args);
}

}
