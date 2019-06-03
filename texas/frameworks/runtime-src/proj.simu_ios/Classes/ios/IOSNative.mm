//
//  IOSNative.m
//  texas
//
//  Created by qf on 14-11-18.
//
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCrypto.h>
#import "IOSNative.h"
#import "QImagePicker.h"
#import <AudioToolbox/AudioToolbox.h>

#include "ImagePostHelper.h"
#include "cocos2d.h"
#include "webview/ZYWebView.h"
#include "IOSPay.h"
#include "CCLuaEngine.h"
#include "CCLuaBridge.h"
#include "QNative.h"
#include "KeyboardListen.h"
#include "Reachability.h"


@implementation IOSNative

int _loginType;

+ (void) init {
}

void _sdkAccountLogin(NSDictionary *args){
}
void _sdkShare(NSDictionary *args){
}


+ (void) sharePic:(NSDictionary *)args {
    sharePicLuaCallBack = [[args objectForKey:@"cb"] intValue];
    _sdkShare(args);
}

+(void ) sharePicCallBack:(int)ret {
    cocos2d::LuaBridge::pushLuaFunctionById(sharePicLuaCallBack);
    cocos2d::LuaBridge::getStack()->pushInt(ret);
    cocos2d::LuaBridge::getStack()->executeFunction(1);
    cocos2d::LuaBridge::releaseLuaFunctionById(sharePicLuaCallBack);
    
}

+( void) sdkAccountLogin:(NSDictionary *)args{
}

+(void) sdkAccountLoginSuccess:(NSDictionary *)args{
}

+(void) qqLoginSuccess{
}

+(void) qqLoginFailed{
}

+ (NSDictionary *) getBaseVersion : (NSDictionary *) args {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appCurVersion = [infoDictionary objectForKey:@"CFBundleVersion"];
    return [NSDictionary dictionaryWithObjectsAndKeys:appCurVersion,@"version", nil];
}


+ (void ) beforePhoto: (NSDictionary * ) args {
    [[QImagePicker getInstance] setPhotoPath:[args objectForKey:@"path"]];
    [[QImagePicker getInstance] setLuaCB:[[args objectForKey:@"cb"] intValue]];
    [[QImagePicker getInstance] setUin:[[args objectForKey:@"uin"] intValue]];
    [[QImagePicker getInstance] setKey:[args objectForKey:@"key"]];
    [[QImagePicker getInstance] setUrl:[args objectForKey:@"url"]];
    [[QImagePicker getInstance] setUpload:[[args objectForKey:@"upload"] intValue]];
    if ([args objectForKey:@"edit"]==nil) {
        [[QImagePicker getInstance] setEdit:1];
    }else {
        [[QImagePicker getInstance] setEdit:[[args objectForKey:@"edit"] intValue]];
    }
   
}

+ (void ) takePhoto:(NSDictionary *)args {
    [self beforePhoto:args];
    [[QImagePicker getInstance] openFromCamare];
}

+ ( void) selectPhoto : (NSDictionary *) args{
    [self beforePhoto:args];
    [[QImagePicker getInstance] openFromAlbum];
}

//
+ (NSDictionary *) getRegInfo:(NSDictionary *)args {

   
    NSString * channel = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"Channel"];
    NSNumber * version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString * packName= [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    // 使用配置好的key
    NSString * key = [NSString stringWithUTF8String: QNative::shareInstance()->getKey().c_str()];
    NSString * uuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    if (![packName isEqualToString:@"com.qufan.texasx"]) {
        uuid = [[packName stringByAppendingString:@":"] stringByAppendingString:uuid];
    }
    NSMutableDictionary * info = [[NSMutableDictionary alloc] init];
    [info setObject:[[ UIDevice currentDevice] name] forKey:@"nick"];
    [info setObject:uuid forKey:@"uuid"];
    [info setObject:@"00:00:00:00:00:00" forKey:@"mac_addr"];
    [info setObject:[[[UIDevice currentDevice] identifierForVendor] UUIDString] forKey:@"device_id"];
    [info setObject:channel forKey:@"channel"];
    [info setObject:version forKey:@"version"];
    [info setObject:[self MD5:[[NSString alloc] initWithFormat:@"%@|%@",key,uuid]] forKey:@"sign"];
    
    return info;
}

+(NSString *) getKey:(NSDictionary *)args
{
    NSString * key = [NSString stringWithUTF8String: QNative::shareInstance()->getKey().c_str()];
    return key;
}

+(NSString *) MD5:(NSString *)input {
    const char * txt = [input UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( txt, (unsigned int)strlen(txt), digest );
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    return  output;
}

+ (NSString *)getLang:(NSDictionary *)args {
    
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"Lang"];
}

+(void)showWebView:(NSDictionary *)args {
    int x = [[args objectForKey:@"x"] intValue];
    int y = [[args objectForKey:@"y"] intValue];
    int w = [[args objectForKey:@"w"] intValue];
    int h = [[args objectForKey:@"h"] intValue];
    int cb = [[args objectForKey:@"cb"] intValue];
    int cb2 = [[args objectForKey:@"cb2"] intValue];
    NSString * url = [args objectForKey:@"url"];
    
    ZYWebView::getInstance()->showWebView([url UTF8String], x, y, w, h,cb,cb2);
}

-(void)tagsAliasCallback:(int)iResCode
                    tags:(NSSet*)tags
                   alias:(NSString*)alias
{
    //    jpushTags = tags;
}
+ (void) bindJpushAlias:( NSDictionary * ) args{
}


+ (void) jpushAddTag:( NSDictionary * ) args
{
}

+ (void) jpushDeleteTag:( NSDictionary * ) args
{
}

+ (void)removeWebView:(NSDictionary *)args{
    ZYWebView::getInstance()->removeWebView();
}


+(void) umengStatistics:(NSDictionary *)args {
    
}
+(void) playVibrate:(NSDictionary *)args {
    AudioServicesPlaySystemSound ( kSystemSoundID_Vibrate) ;
}

+ (void)requestApplyAuth:(NSDictionary *)args {
    NSDictionary * life = [[NSDictionary alloc] initWithObjectsAndKeys:[args objectForKey:@"lifek"],@"name",@"life.png",@"filename",[args objectForKey:@"spotPhoto"],@"path", nil];
    NSDictionary * spot = [[NSDictionary alloc] initWithObjectsAndKeys:[args objectForKey:@"spotk"],@"name",@"spot.png",@"filename",[args objectForKey:@"livePhoto"],@"path", nil];
    
    NSArray * arr = [[NSArray alloc] initWithObjects:life,spot, nil];
    NSNumber * uin = [args objectForKey:@"uin"];
    NSString * key = [args objectForKey:@"key"];
    [ImagePostHelper requestApplyAuth:[args objectForKey:@"url"] postParems:[[NSMutableDictionary alloc] initWithObjectsAndKeys:uin,@"uin",key,@"key", nil] picInfo:arr luacb:[[args objectForKey:@"cb"] intValue]];
}

+ (void)removeDir:(NSDictionary *)args {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString * path = [args objectForKey:@"path"];
    [fileManager removeItemAtPath:path error:nil];
}


+ (void)pay:(NSDictionary *)args {
    [IOSPay pay:args];
}
+ (void) initPay {
    [IOSPay initPay];
}
+ (void) handleOpenurl:(NSURL *)url{
    if (payInstance and [payInstance respondsToSelector:@selector(handleOpenurl:)]) {
        [payInstance handleOpenurl:url];
    }
    
}

+ (void) uploadError:(NSDictionary *)args{
    NSURL *URL=[NSURL URLWithString:[args objectForKey:@"host"]];//不需要传递参数
    
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:URL];//默认为get请求
    request.timeoutInterval=5.0;//设置请求超时为5秒
    request.HTTPMethod=@"POST";//设置请求方法
    
    //设置请求体
    NSString *param=[NSString stringWithFormat:@"uin=%@&os=%@&channel=%@&version=%@&content=%@&debug=%@",[args objectForKey:@"uid"],@"ios",[args objectForKey:@"channel"],[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],[args objectForKey:@"content"],[args objectForKey:@"debug"]];
    
    [request setHTTPBody:[param dataUsingEncoding:NSUTF8StringEncoding]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError * error) {
        //这段块代码只有在网络请求结束以后的后续处理。
        if (data != nil) {  //接受到数据，表示工作正常
            NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        }else if(data == nil && error != nil)    //没有接受到数据，但是error为nil。。表示接受到空数据。
        {
        }else{
        }
    }];
}

+(void) feedBack : (NSDictionary *) args{
    
}

+(NSDictionary *) initWxAndQQShow : (NSDictionary *) args{
    NSMutableDictionary* info = [[NSMutableDictionary alloc] init];
    NSString *can_show = @"0";
    [info setObject:can_show forKey:@"QQ_CAN_SHOW"];
    [info setObject:can_show forKey:@"WX_CAN_SHOW"];
    return info;
}

+ (NSDictionary *) payCallback:(NSDictionary *)args {
    int cb = [[args objectForKey:@"cb"] intValue];
    return nil;
}

+(UIViewController *) getRootController{
    UIViewController * _rootController ;
    if ( [[UIDevice currentDevice].systemVersion floatValue] < 6.0)
    {
        NSArray* array=[[UIApplication sharedApplication]windows];
        UIWindow* win=[array objectAtIndex:0];
        
        UIView* ui=[[win subviews] objectAtIndex:0];
        _rootController = (UIViewController*)[ui nextResponder];
    }
    else
    {
        _rootController =[[[UIApplication sharedApplication] keyWindow ] rootViewController];
    }
    return _rootController;
}
+(int) getLoginType{
    return _loginType;
}

+(void) wxGetCodeSuccess:(NSDictionary *)args{
    NSError *parseError = nil;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:args options:NSJSONWritingPrettyPrinted error:&parseError];
    NSString * jsonstr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    cocos2d::LuaBridge::pushLuaFunctionById(loginCallback);
    cocos2d::LuaBridge::getStack()->pushString([jsonstr cStringUsingEncoding:NSUTF8StringEncoding]);
    cocos2d::LuaBridge::getStack()->executeFunction(1);
    cocos2d::LuaBridge::releaseLuaFunctionById(loginCallback);
}

+(int) isSmsVerificationEnabled : (NSDictionary *)args
{
    return 0;
}
+(void) getSmsVerificationCode : (NSDictionary *)args
{
}
+(void) getVoiceVerificationCode : (NSDictionary *)args
{
}


+ (void) shareToWeixinForIOS{
}

// share to QQ
+ (void)sdkShareToQQ:(NSDictionary *)args {
}
// share to WX
+ (void)sdkshareToWX:(NSDictionary *)args {
}
// share
+ (void) sdkShare:(NSDictionary *)args {
}
// 分享结果
+ (void)sdkShareResultCallback : (NSDictionary*)args {
}
// 执行Lua回调
+ (void)executeLuaSdkShareCallback : (NSDictionary *)args {
}

+(void) sendSms:(NSDictionary *)args {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SEND_SMS" object:nil userInfo:args];
}
// 获取包信息中的第几个url types
+ (NSDictionary *)getBoundleUrlTypes : (NSInteger)item {
    NSDictionary* dictInfo = [[NSBundle mainBundle] infoDictionary];
    NSArray* urlTypes = [dictInfo objectForKey:@"CFBundleURLTypes"];
    return [urlTypes objectAtIndex:item];
}

// 获取QQ APPID
+ (NSString *)getQqAppId {
    NSDictionary* qqInfo = [self getBoundleUrlTypes:0];
    NSString* qqAppId = [[qqInfo objectForKey:@"CFBundleURLSchemes"] objectAtIndex:0];
    qqAppId = [qqAppId substringFromIndex:7];
    return qqAppId;
}
// 获取微信APPID
+ (NSString *)getWxAppId {
    NSDictionary* wxInfo = [self getBoundleUrlTypes:1];
    NSString* wxAppId = [[wxInfo objectForKey:@"CFBundleURLSchemes"] objectAtIndex:0];
    return wxAppId;
}
// 获取Ali的URL scheme
+ (NSString*)getAliUrlScheme {
    NSDictionary* aliInfo = [self getBoundleUrlTypes:2];
    NSString* aliAppId = [[aliInfo objectForKey:@"CFBundleURLSchemes"] objectAtIndex:0];
    return aliAppId;
}
// 获取微信SECRET:不在客户端配置2016/04/19
// + (NSString *)getWxSecret {
//     NSDictionary* dictInfo = [[NSBundle mainBundle] infoDictionary];
//     NSString* wxSecret = [dictInfo objectForKey:@"WxAppSecret"];
//     return wxSecret;
// }
// 是否连接了Wifi
+ (int) isEnabledWifi : (NSDictionary *)args {
    return ([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] == ReachableViaWiFi);
}
// 是否连接了gprs
+ (int) isEnabledGPRS : (NSDictionary *)args {
    return ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == ReachableViaWWAN);
}
// 获取剩余电池电量
+ (int) getBatteryLevel : (NSDictionary *)args {
    UIDevice.currentDevice.batteryMonitoringEnabled = true;
    float batteryLvl = [UIDevice currentDevice].batteryLevel;
    UIDevice.currentDevice.batteryMonitoringEnabled = false;

    if(batteryLvl < 0)
    {
        //电量获取失败
        return 100;
    }
    else
    {
        //电量获取成功
        int level = (int)(batteryLvl * 100);
        level = level > 100 ? 100 : level;
        return level;
    }
}

// 开始语音识别
+ (int) startVoiceRecognition : (NSDictionary *)args {
    return 0;
}
// 结束语音识别
+ (void) finishVoiceRecognition : (NSDictionary *)args {
}
// 取消语音识别
+ (void) cancelVoiceRecognition : (NSDictionary *)args {
}
// 获取用户输入语音音量
+ (int) getVoiceRecognitionVolume : (NSDictionary *)args {
    return 0;
}

+(void) listenKeyboardShow: (NSDictionary*)args
{
    KeyboardListen * key=  [KeyboardListen getInstance];
    key.show_cb=[[args objectForKey:@"show_cb"] intValue];
    key.delete_cb=[[args objectForKey:@"delete_cb"] intValue];
    key.x_rate=[[args objectForKey:@"x_rate"] floatValue];
}
+(void) listenKeyboardHide: (NSDictionary*)args
{
    KeyboardListen * key=  [KeyboardListen getInstance];
    key.hide_cb=[[args objectForKey:@"hide_cb"] intValue];
    
}
+ (void) closeKeyboard: (NSDictionary*)args
{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
}

+ (void) openKeyboard: (NSDictionary*)args
{
    [[NSNotificationCenter defaultCenter] postNotificationName:
     @"Notification_showLuaEditBox" object:self userInfo:nil];
    
}
+ (void) getIosVersion: (NSDictionary*)args
{
     int cb=[[args objectForKey:@"cb"] intValue];
    float version=[[[UIDevice currentDevice] systemVersion] floatValue];
    cocos2d::LuaBridge::pushLuaFunctionById(cb);
    cocos2d::LuaBridge::getStack()->pushFloat(version);
    cocos2d::LuaBridge::getStack()->executeFunction(1);
}


//talkingdata
+ (void) td_onRegister:(NSDictionary *)args
{
}

+ (void) td_onLogin:(NSDictionary *)args
{
}

+ (void) td_onPay:(NSString *)userId withOrderId:(NSString *)orderId withAmount:(int)amount withCurrencyType:(NSString *)currencyType withPayType:(NSString *)payType;
{
}

+ (void) sendUinToBugly: (NSDictionary*)args
{
}


+ (void) haimaLogin : ( NSDictionary * ) args
{
}
+ (void) haimaLoginCallback : (NSString *)userId Token:(NSString *)token
{
    }

@end

