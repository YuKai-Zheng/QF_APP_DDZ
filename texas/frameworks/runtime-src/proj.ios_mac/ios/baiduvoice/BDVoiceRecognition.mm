#import "BDVoiceRecognition.h"
#import "BDVRLogger.h"
#include "CCLuaEngine.h"
#include "CCLuaBridge.h"

//语音识别key, 更换百度开发者账号或重新创建应用时需要替换
//Lynn开发者账号
//#define API_KEY @"OgvZitEhFzRbtuG4wy8lcYBG"
//#define SECRET_KEY @"bC9p7EF3Bz28assaiicpF6j6uRuCmhkl"
//qufan开发者账号
#define API_KEY @"snUsLblrohWITZuFGrmMQwv6WY7YEGCq"
#define SECRET_KEY @"lSzekZ5AqBjVrtWoayzCYjmfj7cboPde"


// 私有方法分类
@interface BDVoiceRecognition ()
- (void) initLuaCallback:(int)cb;
- (void) excuteLuaCallback:(int)status errcode:(int)errcode result:(NSString*)result;
- (void) releaseLuaCallback;
@end// VoiceRecognitonViewController


@implementation BDVoiceRecognition

// 识别结果
static int s_recognitionHandler = -1;

- (void)initParams
{
    // 设置开发者信息
    [[BDVoiceRecognitionClient sharedInstance] setApiKey:API_KEY withSecretKey:SECRET_KEY];
    
    // 设置log级别
    [BDVRLogger setLogLevel:BDVR_LOG_OFF];
    
    // 设置语音识别模式，默认是输入模式
    [[BDVoiceRecognitionClient sharedInstance] setPropertyList: @[[NSNumber numberWithInt: EVoiceRecognitionPropertyGame]]];
    
    // 设置识别语言
    [[BDVoiceRecognitionClient sharedInstance] setLanguage: EVoiceRecognitionLanguageChinese];
    
    // 打开语音音量监听功能
    [[BDVoiceRecognitionClient sharedInstance] listenCurrentDBLevelMeter];
    
    // 设置播放开始说话提示音开关，可选
    [[BDVoiceRecognitionClient sharedInstance] setPlayTone:EVoiceRecognitionPlayTonesRecStart isPlay:YES];
    
    // 设置播放结束说话提示音开关，可选
    [[BDVoiceRecognitionClient sharedInstance] setPlayTone:EVoiceRecognitionPlayTonesRecEnd isPlay:YES];
    
    // 设置识别端
    [[BDVoiceRecognitionClient sharedInstance] setLocalVAD:NO];
    [[BDVoiceRecognitionClient sharedInstance] setServerVAD:NO];
    
}

// 开始录音.
//  cb: 用户回调
//      参数1: int类型, 状态描述. 0, 识别工作开始; 1, 识别工作结束; 2, 中间结果更新; 3, 最终结果; 4, 用户取消; 5, 出现错误.
//      参数2: int类型, 错误码.
//      参数3: NSString* 类型. 结果 或 错误描述;
- (int) start:(int)cb
{
    int status = [[BDVoiceRecognitionClient sharedInstance] startVoiceRecognition:self];
    NSLog(@"[VR]Start recognition. %d", status);
    if (status == EVoiceRecognitionStartWorking)
    {
        [self initLuaCallback:cb];
        return 1;
    }
    else {
        return 0;
    }
}

// 停止 BDVRClient 的识别过程,该方法会释放相应的资源,并向接受识别结果接口中发送用户取消通知。
- (void) cancel
{
    [[BDVoiceRecognitionClient sharedInstance] stopVoiceRecognition];
}

// 结束语音识别,录音完成,此后可以放心地等待结果返回和状态通知,不需要添加额外代码
- (void) finish
{
    [[BDVoiceRecognitionClient sharedInstance] speakFinish];
}

// 获取音量级别
- (int) getVolume
{
    int voiceLevel = [[BDVoiceRecognitionClient sharedInstance] getCurrentDBLevelMeter];
    return voiceLevel;
}

//初始化用户回调
- (void) initLuaCallback:(int)cb
{
    s_recognitionHandler = cb;
}

// 执行用户回调.
- (void) excuteLuaCallback:(int)status errcode:(int)errcode result:(NSString*)result
{
    if (s_recognitionHandler != -1)
    {
        cocos2d::LuaBridge::pushLuaFunctionById(s_recognitionHandler);
        cocos2d::LuaBridge::getStack()->pushInt(status);
        cocos2d::LuaBridge::getStack()->pushInt(errcode);
        cocos2d::LuaBridge::getStack()->pushString([result cStringUsingEncoding:NSUTF8StringEncoding]);
        cocos2d::LuaBridge::getStack()->executeFunction(3);
    }
}

//释放用户回调
- (void) releaseLuaCallback
{
    if (s_recognitionHandler != -1)
    {
        cocos2d::LuaBridge::releaseLuaFunctionById(s_recognitionHandler);
        s_recognitionHandler = -1;
    }
}


#pragma mark - MVoiceRecognitionClientDelegate
// 语音识别库工作状态
- (void)VoiceRecognitionClientWorkStatus:(int)aStatus obj:(id)aObj
{
    if (aStatus != 9)
    {
        NSLog(@"[VR]Working. %d",aStatus);
    }
    
    switch (aStatus)
    {
        // 识别库开始识别工作，用户可以说话
        case EVoiceRecognitionClientWorkStatusStartWorkIng:
        {
            [self excuteLuaCallback:STT_START_WORK errcode:0 result:@""];
            break;
        }
        // 用户说话完成，等待服务器返回识别结果
        case EVoiceRecognitionClientWorkStatusEnd:
        {
            [self excuteLuaCallback:STT_END_WORK errcode:0 result:@""];
            break;
        }
        // 用户取消
        case EVoiceRecognitionClientWorkStatusCancel:
        {
            [self excuteLuaCallback:STT_USER_CANCEL errcode:0 result:@""];
            [self releaseLuaCallback];
            break;
        }
        // 连续上屏中间结果
        case EVoiceRecognitionClientWorkStatusFlushData:
        {
            NSString *text = [aObj objectAtIndex:0];
            
            if ([text length] > 0)
            {
                [self excuteLuaCallback:STT_REFRESH_TEXT errcode:0 result:text];
            }
            break;
        }
        // 识别正常完成并获得结果
        case EVoiceRecognitionClientWorkStatusFinish:
        {
            NSMutableArray *audioResultData = (NSMutableArray *)aObj;
            NSString *text = [audioResultData objectAtIndex:0];
            
            if ([text length] > 0)
            {
                [self excuteLuaCallback:STT_RESULT errcode:0 result:text];
            }
            else
            {
                [self excuteLuaCallback:STT_ERROR errcode:STT_ERRCODE_UNKNOWN_ERROR result:@"无法识别"];
            }
            [self releaseLuaCallback];
            
            break;
        }
        // 输入模式下有识别结果返回
        case EVoiceRecognitionClientWorkStatusReceiveData:
        {
            break;
        }
        //录音数据回调
        case EVoiceRecognitionClientWorkStatusNewRecordData:
        {
            break;
        }
        case EVoiceRecognitionClientWorkStatusNone:
        case EVoiceRecognitionClientWorkStatusStart:
        {
            break;
        }
        case EVoiceRecognitionClientWorkPlayStartTone:
        case EVoiceRecognitionClientWorkPlayStartToneFinish:
        {
            break;
        }
        case EVoiceRecognitionClientWorkPlayEndToneFinish:
        case EVoiceRecognitionClientWorkPlayEndTone:
        {
            break;
        }
        default:
        {
            break;
        }
    }
}
// 网络状态
- (void)VoiceRecognitionClientNetWorkStatus:(int) aStatus
{
    NSLog(@"[VR]Network status. %d", aStatus);
    switch (aStatus)
    {
        case EVoiceRecognitionClientNetWorkStatusStart:
        {
            break;
        }
        case EVoiceRecognitionClientNetWorkStatusEnd:
        {
            break;
        }          
    }
}
// 错误信息
- (void)VoiceRecognitionClientErrorStatus:(int) aStatus subStatus:(int)aSubStatus
{
    NSLog(@"[VR]Error status. %d - %d",aStatus,aSubStatus);
    NSString *errorMsg = @"";
    int errorCode = STT_ERRCODE_UNKNOWN_ERROR;
    
    switch (aStatus)
    {
        case EVoiceRecognitionClientErrorStatusIntrerruption:
        {
            errorMsg = @"录音中断";
            break;
        }
        case EVoiceRecognitionClientErrorStatusChangeNotAvailable:
        {
            errorMsg = @"麦克风临时被占用";
            break;
        }
        case EVoiceRecognitionClientErrorStatusUnKnow:
        {
            errorMsg = @"一般错误";
            break;
        }
        case EVoiceRecognitionClientErrorStatusNoSpeech:
        {
            errorMsg = @"用户没有说话";
            errorCode = STT_ERRCODE_RECORD_TOO_SHORT;
            break;
        }
        case EVoiceRecognitionClientErrorStatusShort:
        {
            errorMsg = @"用户说话声太短，比如咳嗽";
            errorCode = STT_ERRCODE_RECORD_TOO_SHORT;
            break;
        }
        case EVoiceRecognitionClientErrorStatusException:
        {
            errorMsg = @"前端库出现异常";
            break;
        }
        case EVoiceRecognitionClientErrorNetWorkStatusError:
        {
            errorMsg = @"网络连接错误, 请重试";
            errorCode = STT_ERRCODE_NETWORK_EXECEPTION;
            break;
        }
        case EVoiceRecognitionClientErrorNetWorkStatusUnusable:
        {
            errorMsg = @"没有网络连接";
            errorCode = STT_ERRCODE_NETWORK_EXECEPTION;
            break;
        }
        case EVoiceRecognitionClientErrorNetWorkStatusTimeOut:
        {
            errorMsg = @"网络超时";
            errorCode = STT_ERRCODE_NETWORK_EXECEPTION;
            break;
        }
        case EVoiceRecognitionClientErrorNetWorkStatusParseError:
        {
            errorMsg = @"服务器数据解析错误";
            break;
        }
        case EVoiceRecognitionStartWorkNoAPIKEY:
        {
            errorMsg = @"没有设置API KEY";
            break;
        }
        case EVoiceRecognitionStartWorkGetAccessTokenFailed:
        {
            errorMsg = @"获取token出现错误";
            break;
        }
        case EVoiceRecognitionStartWorkDelegateInvaild:
        {
            errorMsg = @"没有实现语音识别代理方法";
            break;
        }
        case EVoiceRecognitionStartWorkNetUnusable:
        {
            errorMsg = @"没有网络连接";
            errorCode = STT_ERRCODE_NETWORK_EXECEPTION;
            break;
        }
        case EVoiceRecognitionStartWorkRecorderUnusable:
        {
            errorMsg = @"没有检测到麦克风";
            break;
        }
        case EVoiceRecognitionStartWorkNOMicrophonePermission:
        {
            errorMsg = @"没有麦克风使用权限，请在系统“设置”→“隐私”→“麦克风”中打开开关";
            errorCode = STT_ERRCODE_DEVICE_PREMISSION;
            break;
        }
            //服务器返回错误
        case EVoiceRecognitionClientErrorNetWorkStatusServerNoFindResult:     //没有找到匹配结果
        case EVoiceRecognitionClientErrorNetWorkStatusServerSpeechQualityProblem:    //声音过小
            
        case EVoiceRecognitionClientErrorNetWorkStatusServerParamError:       //协议参数错误
        case EVoiceRecognitionClientErrorNetWorkStatusServerRecognError:      //识别过程出错
        case EVoiceRecognitionClientErrorNetWorkStatusServerAppNameUnknownError: //appName验证错误
        case EVoiceRecognitionClientErrorNetWorkStatusServerUnknownError:      //未知错误
        {
            errorMsg = @"服务器返回错误! ";
            break;
        }
        default:
        {
            errorMsg = @"未知错误";
            break;
        }
    }
    
    NSString* errorMsgWithCode = [NSString stringWithFormat:@"%@  错误码:%d", errorMsg, aStatus];
    [self excuteLuaCallback:STT_ERROR errcode:errorCode result:errorMsgWithCode];
    [self releaseLuaCallback];
}
@end




