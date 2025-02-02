//
// Created by dantezhu on 14-10-23.
//


#ifndef __FerryScript_2014_10_23_H_
#define __FerryScript_2014_10_23_H_

#include "ferry/Ferry.h"
#include "cocos2d.h"


namespace ferry {

class ScriptCallbackEntry;
class ScriptRspCallbackContainer;
class ScriptEventCallbackContainer;

class ScriptEvent: public cocos2d::Ref {
public:
    ScriptEvent() {
        what = 0;
        box = NULL;
        code = 0;
    }
    virtual ~ScriptEvent() {}

    CREATE_FUNC(ScriptEvent);

    bool init() {return true;}

    int getWhat() {
        return what;
    }

    netkit::IBox* getBox() {
        return box;
    }

    int getCode() {
        return code;
    }

    int what;
    netkit::IBox *box;
    int code;
};

class ScriptFerry : public Ferry {
public:
    static ScriptFerry * getInstance();

    virtual ~ScriptFerry();

    void scriptDelCallbacksForTarget(cocos2d::Ref* target);
    void scriptDelAllCallbacks();

    int scriptSend(netkit::IBox *box, int handler, float timeout, cocos2d::Ref *target);
    void scriptDelRspCallback(int entryID);
    void scriptDelRspCallbacksForTarget(cocos2d::Ref *target);
    void scriptDelAllRspCallbacks();

    int scriptAddEventCallback(int handler, cocos2d::Ref *target);
    void scriptDelEventCallback(int entryID);
    void scriptDelEventCallbacksForTarget(cocos2d::Ref *target);
    void scriptDelAllEventCallbacks();

    virtual netkit::IBox *createBox();

protected:
    virtual void update();

    virtual void onEvent(Event *event);

    void scriptOnEvent(Event *event);
    void scriptCheckRspTimeout();

    void scriptHandleWithRspCallbacks(ScriptEvent *event);
    void scriptHandleWithEventCallbacks(ScriptEvent *event);

protected:
    std::list<ScriptEventCallbackContainer*> m_scriptEventCallbacks;
    std::list<ScriptRspCallbackContainer*> m_scriptRspCallbacks;
};


}
#endif //__FerryScript_2014_10_23_H_
