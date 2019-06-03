//
// Created by dantezhu on 14-10-22.
//

#ifndef __FERRY_H_20170420103957__
#define __FERRY_H_20170420103957__

#include "BaseFerry.h"

namespace ferry {
class Ferry : public BaseFerry {
public:
    static Ferry *getInstance();

    virtual ~Ferry();

    virtual int start();
    virtual void stop();

    // 暂停schedule
    virtual void pauseSchedule();
    // 恢复schedule
    virtual void resumeSchedule();
    // 是否被暂停了
    virtual bool isSchedulePaused();

protected:
    virtual void startSchedule();
    virtual void stopSchedule();

    virtual void log(const char *format, ...);
};

}

#endif /* __FERRY_H_20170420103957__ */
