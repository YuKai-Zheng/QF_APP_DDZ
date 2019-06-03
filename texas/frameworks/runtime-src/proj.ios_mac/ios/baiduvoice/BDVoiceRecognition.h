#import "BDVRFileRecognizer.h"

// stt状态码
enum SpeechToTextStatus
{
    STT_START_WORK = 0, //识别工作开始
    STT_END_WORK,       //识别工作结束
    STT_REFRESH_TEXT,   //中间结果更新
    STT_RESULT,         //最终结果
    STT_USER_CANCEL,    //用户取消
    STT_ERROR           //出现错误
};
// 自定义ErrorCode
enum SpeechToTextErrorCode
{
    STT_ERRCODE_RECORD_TOO_SHORT = 100001,  //录音太短
    STT_ERRCODE_DEVICE_PREMISSION,          //无设备权限
    STT_ERRCODE_NETWORK_EXECEPTION,         //网络连接异常
    STT_ERRCODE_UNKNOWN_ERROR               //未知错误
};

@interface BDVoiceRecognition : NSObject<MVoiceRecognitionClientDelegate>
{
}
- (void) initParams;
- (int) start:(int)cb;
- (void) cancel;
- (void) finish;
- (int) getVolume;
@end


