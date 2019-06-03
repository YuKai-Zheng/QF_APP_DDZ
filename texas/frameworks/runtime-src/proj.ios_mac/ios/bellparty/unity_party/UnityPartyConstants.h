
#ifndef __UNITYPARTYCONSTANTS_H_20170222172401__
#define __UNITYPARTYCONSTANTS_H_20170222172401__

// 版本号
static const int VERSION = 2017031009;

static NSString* const OS = @"ios";

static NSString* const SCHEME_HTTP = @"https";

// 超时时间
static const double HTTP_TIMEOUT = 30;

// 任务队列大小。这里设置为3是经过测试的，再大系统就会限制
static const int TASK_QUEUE_MAX_SIZE = 3;

static NSString* const URL_PATH_ALLOC_BELL = @"L2JpbGwvYWxsb2NfdjI=";
static NSString* const URL_PATH_APP_PARTY_CB = @"L2FwcC9wYXkvY2I=";
static NSString* const URL_PATH_BELL_RESULT = @"L2JpbGwvcmVzdWx0";


static const int RESULT_HTTP_PARAMS_INVALID = -100;
static const int RESULT_HTTP_FAIL = -101;
static const int RESULT_SIGN_INVALID = -103;
static const int RESULT_HTTP_CANCEL = -104;
static const int RESULT_EXCEPTION = -201;


// SDK层支付结果。在这里统一定义，这样调用方更简单一些。
// 一定要使用正值，代表sdk层的错误
// 不知道支付成功还是失败，等待服务器结果吧
static const int PARTY_RESULT_WAIT_CONFIRM = 10;
// 用户主动取消支付
static const int PARTY_RESULT_USER_CANCEL = 11;
static const int PARTY_RESULT_FAIL = 12;




#endif /* __UNITYPARTYCONSTANTS_H_20170222172401__ */
