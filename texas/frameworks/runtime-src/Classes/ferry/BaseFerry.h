//
// Created by dantezhu on 14-10-22.
//


#ifndef __BASEFERRY_H_20170420094941__
#define __BASEFERRY_H_20170420094941__

#include <iostream>
#include <string>
#include <list>
#include <functional>

#if defined(_WIN32) || (defined(CC_TARGET_PLATFORM) && CC_TARGET_PLATFORM==CC_PLATFORM_WIN32)
// 这里winsock2.h和Windows.h的顺序一定不能交换，否则一堆问题
#include <winsock2.h>
#include <Windows.h>
#include <time.h>
#else
#include <sys/time.h>
#endif
#include <pthread.h>

#include "Delegate.h"

namespace ferry {

class Service;
struct RspCallbackContainer;
struct EventCallbackContainer;

class Event {
public:
    Event() {
        what = 0;
        box = NULL;
        code = 0;
    }

    virtual ~Event() {
        if(box) {
            delete box;
        }
        box = NULL;
    }

public:
    int what;
    netkit::IBox *box;
    int code;
};

// 事件注册的回调
typedef std::function<void(Event*)> CallbackType;

class BaseFerry : public Delegate {
public:
    static BaseFerry *getInstance();

    BaseFerry();

    virtual ~BaseFerry();

    virtual int init(const std::string &host, int port);

    // 设置消息队列大小
    void setSendMsgQueueMaxSize(int maxsize);

    // 设置连接失败后的重连间隔
    void setConnectTryInterval(float interval);

    // 设置连接超时
    void setConnectTimeout(int timeout);

    virtual int start();

    virtual void stop();

    void connect();

    void disconnect();

    // 清空所有事件
    void clearEvents();

    bool isConnected();

    bool isRunning();

    long long getLastActiveTime();

    // 给外面主线程调用，用来处理事件等
    virtual void update();

    // 删除类对应的所有回调，务必在使用ferry的类的析构函数里调用
    void delCallbacksForTarget(void *target);
    // 删除所有回调
    void delAllCallbacks();

    // 发送消息(线程安全)
    void send(netkit::IBox *box);
    // 带回调的发送，以及超时，超时为秒。target很有用，可以用来防止崩溃
    // callback 会收到 SEND, RECV, ERROR, TIMEOUT 事件
    void send(netkit::IBox *box, CallbackType callback, float timeout, void* target);

    // 删除send对应的回调
    void delRspCallbacksForTarget(void *target);
    void delAllRspCallbacks();

    // 注册事件回调
    // callback 会收到 OPEN, CLOSE, SEND, RECV, ERROR, TIMEOUT 事件
    // 派给RspCallback的请求，不会再EventCallback中收到
    void addEventCallback(CallbackType callback, void* target, const std::string& name);
    void delEventCallback(const std::string& name, void* target);
    void delEventCallbacksForTarget(void *target);
    void delAllEventCallbacks();

protected:
    // 日志，可以继承重写
    virtual void log(const char *format, ...);

    // Delegate begin
    virtual void onOpen(Service *service);
    virtual void onSend(Service *service, netkit::IBox *ibox);
    virtual void onRecv(Service *service, netkit::IBox *ibox);
    virtual void onClose(Service *service);
    virtual void onError(Service *service, int code, netkit::IBox *ibox);
    virtual void onTimeout(Service *service);
    virtual netkit::IBox *createBox();
    virtual void releaseBox(netkit::IBox* ibox);
    // Delegate end

    // 继承后可以修改
    virtual void onEvent(Event *event);
    virtual void postEvent(Event *event);

    virtual void setSnToBox(netkit::IBox* ibox, int sn);
    virtual int getSnFromBox(netkit::IBox* ibox);

    void loopEvents();
    void checkRspTimeout();

    int newBoxSn();

    void handleWithRspCallbacks(Event *event);
    void handleWithEventCallbacks(Event *event);

    // 封装出来，给继承的类调用
    // 可以避免对方引用Service.h
    void sendByService(netkit::IBox* box);

    // 为了解决平台兼容性而重新封装的
    int getTimeOfDay(struct timeval *tp);
    void timerAdd(struct timeval *tvp, struct timeval *uvp, struct timeval *vvp);

protected:
    Service *m_service;

    pthread_mutex_t m_eventsMutex;
    std::list<Event*> m_events;

private:
    pthread_mutex_t m_boxSnMutex;
    int m_boxSn;

    std::list<EventCallbackContainer*> m_eventCallbacks;
    // 最先过期的排在最左边
    std::list<RspCallbackContainer*> m_rspCallbacks;
};

}

#endif /* __BASEFERRY_H_20170420094941__ */
