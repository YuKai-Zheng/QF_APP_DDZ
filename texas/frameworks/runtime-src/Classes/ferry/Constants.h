#ifndef __CONSTANTS_H_20141025154555__
#define __CONSTANTS_H_20141025154555__

namespace ferry {
    // 版本号
    const int VERSION = 231;

    // 等待下次连接时间(秒)
    const float CONNECT_TRY_INTERVAL = 1;

    // 连接超时(秒)
    const int CONNECT_TIMEOUT = 5;

    // 发送队列大小(-1为不限制)
    const int SEND_MSG_QUEUE_MAX_SIZE = 100;

    // 初始recv buf大小
    const int RECV_BUF_INIT_SIZE = 1024;

    enum EVENT_TYPE {
        EVENT_OPEN = 1,
        EVENT_SEND,
        EVENT_RECV,
        EVENT_CLOSE,
        EVENT_ERROR,
        EVENT_TIMEOUT,
    };

    enum ERROR_CODE {
        ERROR_OPEN = 1,
        ERROR_SEND,
    };

}

#endif /* end of include guard: __CONSTANTS_H_20141025154555__ */

