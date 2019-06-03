
//
//  LuaMutual.mm
//  texas
//
//  Created by zny on 14-11-18.
//  Modified by tomas on 17-8-2
//
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCrypto.h>
#import "LuaMutual.h"
#import "HYCutPictures.h"

#import "UMMobClick/MobClick.h"
//#import "UMFeedback.h"

//#import <BCHybridWebViewFMWK/BCHybridWebView.h>
//#import <YWFeedbackFMWK/YWFeedbackKit.h>
//#import <YWFeedbackFMWK/YWFeedbackViewController.h>

#import <AudioToolbox/AudioToolbox.h>
#import <AdSupport/ASIdentifierManager.h>
#import "wxSDK.h"
#import "qqSdk.h"
#if SDK_ACCOUNT == SDK_FACEBOOK_ACCOUNT
#import "facebook/FacebookUtil.h"
#endif

#include "HYPicturesUtil.h"
#include "cocos2d.h"
#include "webview/ZYWebView.h"

#import "UnitySDKPartyFactory.h"

#include "CCLuaEngine.h"
#include "CCLuaBridge.h"
#include "QNative.h"
#include "HYKeyboardListener.h"
#include "Reachability.h"
#include "BDVoiceRecognition.h"
#include "HYSMSVerification.h"
//#import <SMS_SDK/SMSSDK.h>
//#import <SMS_SDK/Extend/SMSSDK+AddressBookMethods.h>
//#import "TalkingDataAppCpa.h"
#import <Bugly/Bugly.h>

//#ifdef SDK_XYPLATFORM
//#import <XYPlatform/XYPlatform.h>
//#endif

#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <AssetsLibrary/ALAssetsGroup.h>
#import <AssetsLibrary/ALAssetRepresentation.h>
@implementation LuaMutual

int _loginType;
int _thirdApp;
static int s_sdkShareHandler = -1;
//static NSMutableSet * jpushTags = nil;
static BDVoiceRecognition* s_recognition = NULL;
//static YWFeedbackKit *s_feedbackKit = NULL;
static CGRect s_screen_frame =CGRectMake(0,0,0,0);
static int s_haveSetFullScreen =0;
int _loginXY = 0;

+ (void) init {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(zny_qqLoginSuccess) name:kLoginSuccessed object:[qqSdk getInstance]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(zny_qqLoginFailed) name:kLoginFailed object:[qqSdk getInstance]];
    
    [self zny_confuse_code1];
}
    
+(NSString*)zny_confuse_code1 {
    NSString* random_key = @RM_LUA_KEY;
    NSString* random_secret = @RM_LUA_SECRET;
    NSString* random_sign = @RM_LUA_SIGN;
    return [NSString stringWithFormat:@"%@%@%@", random_key, random_secret, random_sign];
}
    
void _sdkAccountLogin(NSDictionary *args){
//    NSArray* permissions = [NSArray arrayWithObjects:
//                            kOPEN_PERMISSION_GET_USER_INFO,
//                            kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
//                            nil];
    [[qqSdk getInstance] zny_loginQQ];
}

void _sdkShare(NSDictionary *args){
    
}

+ (void) syyy_sharePic:(NSDictionary *)args {
    sharePicLuaCallBack = [[args objectForKey:@"cb"] intValue];
    _sdkShare(args);
    
    [self zny_confuse_code2];
}

+(void ) zny_sharePicCallBack:(int)ret {
    cocos2d::LuaBridge::pushLuaFunctionById(sharePicLuaCallBack);
    cocos2d::LuaBridge::getStack()->pushInt(ret);
    cocos2d::LuaBridge::getStack()->executeFunction(1);
    cocos2d::LuaBridge::releaseLuaFunctionById(sharePicLuaCallBack);
}

+(NSString*)zny_confuse_code2 {
    NSString* random_key = @RM_C_KEY;
    NSString* random_secret = @RM_C_SECRET;
    NSString* random_sign = @RM_C_SIGN;
    return [NSString stringWithFormat:@"%@%@%@", random_key, random_secret, random_sign];
}

+( void) syyy_sdkAccountLogin:(NSDictionary *)args{
    loginCallback = [[args objectForKey:@"cb"] intValue];
    int type = [[args objectForKey:@"type"] intValue];
    _loginType = type;
    _thirdApp = type;
    if(_loginType == 1){
        [[qqSdk getInstance] zny_loginQQ];
    }else if (_loginType == 3){
        [[wxSDK getinstance] zny_getCode];// 微信登陆-得到code－从lua中去得到appid
    }
    
    [self zny_confuse_code4];
}

+(void) zny_sdkAccountLoginSuccess:(NSDictionary *)args{
    NSError *parseError = nil;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:args options:NSJSONWritingPrettyPrinted error:&parseError];
    
    NSString * jsonstr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    cocos2d::LuaBridge::pushLuaFunctionById(loginCallback);
    cocos2d::LuaBridge::getStack()->pushString([jsonstr cStringUsingEncoding:NSUTF8StringEncoding]);
    cocos2d::LuaBridge::getStack()->executeFunction(1);
    cocos2d::LuaBridge::releaseLuaFunctionById(loginCallback);
}

+(void) zny_qqLoginSuccess{
    NSDictionary * info = [[qqSdk getInstance] zny_getOpenIDAndToken];
    NSMutableDictionary * addTypeDic = [[NSMutableDictionary alloc] initWithDictionary:info];
    [addTypeDic setObject:@1 forKey:@"type"];
    [self zny_sdkAccountLoginSuccess:addTypeDic];
    
    [self zny_confuse_code5];
}

+(void) zny_qqLoginFailed{
}

+(NSString*)zny_confuse_code3 {
    NSString* random_key = @RM_OC_KEY;
    NSString* random_secret = @RM_OC_SECRET;
    NSString* random_sign = @RM_OC_SIGN;
    return [NSString stringWithFormat:@"%@%@%@", random_key, random_secret, random_sign];
}


+ (void ) zny_beforePhoto: (NSDictionary * ) args {
    [[HYCutPictures getInstance] zny_setPhotoPath:[args objectForKey:@"path"]];
    [[HYCutPictures getInstance] zny_setLuaCB:[[args objectForKey:@"cb"] intValue]];
    [[HYCutPictures getInstance] zny_setUin:[[args objectForKey:@"uin"] intValue]];
    [[HYCutPictures getInstance] zny_setKey:[args objectForKey:@"key"]];
    [[HYCutPictures getInstance] zny_setUrl:[args objectForKey:@"url"]];
    [[HYCutPictures getInstance] zny_setUpload:[[args objectForKey:@"upload"] intValue]];
    if ([args objectForKey:@"edit"]==nil) {
        [[HYCutPictures getInstance] zny_setEdit:1];
    }else {
        [[HYCutPictures getInstance] zny_setEdit:[[args objectForKey:@"edit"] intValue]];
    }
    
    [self zny_confuse_code3];
}

+ (void ) syyy_takePhoto:(NSDictionary *)args {
    [self zny_beforePhoto:args];
    [[HYCutPictures getInstance] zny_openFromCamare];
}

+ ( void) syyy_selectPhoto : (NSDictionary *) args{
    [self zny_beforePhoto:args];
    [[HYCutPictures getInstance] zny_openFromAlbum];
    
    [self zny_confuse_code6];
}
+ (NSString *) syyy_getIDFA {
    NSString *adId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    return [[NSString alloc] initWithFormat:@"%@%@", @"IDFA:", adId];
}
+ (NSString *) syyy_getGameName {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];  
    NSString *appCurName = [infoDictionary objectForKey:@"CFBundleDisplayName"];  
    return appCurName;
}

+ (CGRect) zny_getScreenFrame{
    
    if(s_screen_frame.size.width < 1){
        CGRect frame = [[UIScreen mainScreen] bounds];
        CGFloat height = frame.size.height;
        CGFloat width = frame.size.width;
        if(height / width > 19.0/9.0){
            CGFloat heightOffset = frame.size.height * 0.04;
            frame.size.height -= heightOffset;
            frame.origin.x = heightOffset;
            s_haveSetFullScreen = 1;
        }
        if (width / height > 19.0 / 9.0){
            CGFloat widthOffset = frame.size.width * 0.04;
            frame.size.width -= widthOffset;
            frame.origin.x = widthOffset;
            s_haveSetFullScreen = 1;
        }
        s_screen_frame = frame;
        
    }
    return s_screen_frame;
}
+ (int) syyy_getIfScreenFrame{
    return s_haveSetFullScreen;
}
//
+ (NSDictionary *) syyy_getRegInfo:(NSDictionary *)args {
    NSString* version = [NSString stringWithFormat:@"%d", [self syyy_getVersionCode]];
    NSString * channel = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"Channel"];
    NSString * packName= [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    // 使用配置好的key
    NSString * key = [NSString stringWithUTF8String: QNative::shareInstance()->zny_getKey().c_str()];
    NSString * adId = [self syyy_getIDFA];
    NSString * uuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString * app_name = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    if (![packName isEqualToString:@"com.qufan.texasx"]) {
        uuid = [[packName stringByAppendingString:@":"] stringByAppendingString:uuid];
    }
    NSMutableDictionary * info = [[NSMutableDictionary alloc] init];
    [info setObject:[[ UIDevice currentDevice] name] forKey:@"nick"];
    [info setObject:[[ UIDevice currentDevice] systemVersion] forKey:@"deviceSystemVersion"];
    [info setObject:uuid forKey:@"uuid"];
    [info setObject:@"00:00:00:00:00:00" forKey:@"mac_addr"];
    [info setObject:adId forKey:@"device_id"];
    [info setObject:channel forKey:@"channel"];
    [info setObject:version forKey:@"version"];
    [info setObject:app_name forKey:@"app_name"];
    [info setObject:[self zny_MD5:[[NSString alloc] initWithFormat:@"%@|%@|%@",key,uuid,adId]] forKey:@"sign"];
    
    return info;
}

+(NSString *) syyy_getKey:(NSDictionary *)args
{
    NSString * key = [NSString stringWithUTF8String: QNative::shareInstance()->zny_getKey().c_str()];
    return key;
}

+(NSString *) zny_MD5:(NSString *)input {
    const char * txt = [input UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( txt, (unsigned int)strlen(txt), digest );
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    [self zny_confuse_code3];
    
    return  output;
}

+ (NSString *)syyy_getLang{
    return @"cn";
}

+(void)syyy_showWebView:(NSDictionary *)args {
    int x = [[args objectForKey:@"x"] intValue];
    int y = [[args objectForKey:@"y"] intValue];
    int w = [[args objectForKey:@"w"] intValue];
    int h = [[args objectForKey:@"h"] intValue];
    int cb = [[args objectForKey:@"cb"] intValue];
    int cb2 = [[args objectForKey:@"cb2"] intValue];
    NSString * url = [args objectForKey:@"url"];
    
    ZYWebView::getInstance()->showWebView([url UTF8String], x, y, w, h,cb,cb2);
    
    [self zny_confuse_code3];
}

+(NSString*)zny_confuse_code4 {
    NSString* random_key = @RM_OC_KEY;
    NSString* random_secret = @RM_OC_SECRET;
    NSString* random_sign = @RM_OC_SIGN;
    return [NSString stringWithFormat:@"%@%@%@", random_key, random_secret, random_sign];
}

+ (void)syyy_removeWebView{
    ZYWebView::getInstance()->removeWebView();
    
    [self zny_confuse_code4];
}

+(void) syyy_umengStatistics:(NSDictionary *)args {
    NSString * key = [args objectForKey:@"key"];
    NSString * value = [args objectForKey:@"value"];
    // label为nil或@""时，等同于 event:eventId label:eventId;
    [MobClick event:key label:value];
    
}
+(void) syyy_playVibrate:(NSDictionary *)args {
    AudioServicesPlaySystemSound ( kSystemSoundID_Vibrate) ;
}

+ (void)syyy_requestApplyAuth:(NSDictionary *)args {
    NSDictionary * life = [[NSDictionary alloc] initWithObjectsAndKeys:[args objectForKey:@"lifek"],@"name",@"life.png",@"filename",[args objectForKey:@"spotPhoto"],@"path", nil];
    NSDictionary * spot = [[NSDictionary alloc] initWithObjectsAndKeys:[args objectForKey:@"spotk"],@"name",@"spot.png",@"filename",[args objectForKey:@"livePhoto"],@"path", nil];
    
    NSArray * arr = [[NSArray alloc] initWithObjects:life,spot, nil];
    NSNumber * uin = [args objectForKey:@"uin"];
    NSString * key = [args objectForKey:@"key"];
    [HYPicturesUtil zny_requestApplyAuth:[args objectForKey:@"url"] postParems:[[NSMutableDictionary alloc] initWithObjectsAndKeys:uin,@"uin",key,@"key", nil] picInfo:arr luacb:[[args objectForKey:@"cb"] intValue]];
}

+ (void)syyy_removeDir:(NSDictionary *)args {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString * path = [args objectForKey:@"path"];
    [fileManager removeItemAtPath:path error:nil];
    
    [self zny_confuse_code4];
}


+ (void)syyy_party:(NSDictionary *)args {
    [[UnitySDKPartyFactory getInstance] zny_startParty:args];
}
+ (void) zny_initParty {
    [[UnitySDKPartyFactory getInstance] zny_initParty];
}
+ (void) handleOpenurl:(NSURL *)url{
//    if (payInstance and [payInstance respondsToSelector:@selector(handleOpenurl:)]) {
//        [payInstance handleOpenurl:url];
//    }
    
}

+ (void) syyy_uploadError:(NSDictionary *)args{
    NSURL *URL=[NSURL URLWithString:[args objectForKey:@"host"]];//不需要传递参数
    
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:URL];//默认为get请求
    request.timeoutInterval=5.0;//设置请求超时为5秒
    request.HTTPMethod=@"GET";//设置请求方法
    
    //设置请求体
    NSString *param=[NSString stringWithFormat:@"uin=%@&os=%@&channel=%@&version=%d&content=%@&debug=%@",[args objectForKey:@"uid"],@"ios",[args objectForKey:@"channel"],[self syyy_getVersionCode],[args objectForKey:@"content"],[args objectForKey:@"debug"]];
    
    [request setHTTPBody:[param dataUsingEncoding:NSUTF8StringEncoding]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError * error) {
        //这段块代码只有在网络请求结束以后的后续处理。
        if (data != nil) {  //接受到数据，表示工作正常
        }else if(data == nil && error != nil)    //没有接受到数据，但是error为nil。。表示接受到空数据。
        {
        }else{
        }
    }];
}

+(void) syyy_feedBack : (NSDictionary *) args{
    [self zny_confuse_code1];
}
+(void) syyy_AlibaichuanUnreadRequst: (NSDictionary *)args {
    [self zny_confuse_code2];
}
+(void) zny_initBCFeedback {
    [self zny_confuse_code2];
}

+(NSDictionary *) syyy_initWxAndQQShow : (NSDictionary *) args{
    NSMutableDictionary* info = [[NSMutableDictionary alloc] init];
    [info setObject:[[qqSdk getInstance] zny_getQQCanShow] forKey:@"QQ_CAN_SHOW"];
    [info setObject:[[wxSDK getinstance] zny_getWXCanShow] forKey:@"WX_CAN_SHOW"];
    return info;
}

+ (NSDictionary *) zny_partyCallback:(NSDictionary *)args {
//    int cb = [[args objectForKey:@"cb"] intValue];
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
    
    [self zny_confuse_code6];
    
    return _rootController;
}
+(int) zny_getLoginType{
    return _loginType;
}

+(int) zny_getThirdAppType{
    return _thirdApp;
}

+(void) zny_wxGetCodeSuccess:(NSDictionary *)args{
    NSError *parseError = nil;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:args options:NSJSONWritingPrettyPrinted error:&parseError];
    NSString * jsonstr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    cocos2d::LuaBridge::pushLuaFunctionById(loginCallback);
    cocos2d::LuaBridge::getStack()->pushString([jsonstr cStringUsingEncoding:NSUTF8StringEncoding]);
    cocos2d::LuaBridge::getStack()->executeFunction(1);
    cocos2d::LuaBridge::releaseLuaFunctionById(loginCallback);
    
    [self zny_confuse_code5];
}

+(NSString*)zny_confuse_code5 {
    NSString* random_key = @RM_CPLUS_KEY;
    NSString* random_secret = @RM_CPLUS_SECRET;
    NSString* random_sign = @RM_CPLUS_SIGN;
    return [NSString stringWithFormat:@"%@%@%@", random_key, random_secret, random_sign];
}

+(int) syyy_isSmsVerificationEnabled : (NSDictionary *)args
{
//    bool enabled = [HYSMSVerification isEnabled];
    return 1; //直接返回1 默认可以使用短信验证
}
+(void) syyy_getSmsVerificationCode : (NSDictionary *)args
{
    NSString* zone = [args objectForKey:@"zone"];
    NSString* phone = [args objectForKey:@"phone"];
    int cb = [[args objectForKey:@"cb"] intValue];
    [HYSMSVerification zny_getSMSVerificationCode:zone phoneNum:phone luaCallback:cb];
    
    [self zny_confuse_code4];
}
+(void) syyy_getVoiceVerificationCode : (NSDictionary *)args
{
    NSString* zone = [args objectForKey:@"zone"];
    NSString* phone = [args objectForKey:@"phone"];
    int cb = [[args objectForKey:@"cb"] intValue];
    [HYSMSVerification zny_getVoiceVerificationCode:zone phoneNum:phone luaCallback:cb];
    
    [self zny_confuse_code2];
}

+ (void) syyy_shareToWeixinForIOS{
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = @"标题";
    message.description = @"app描述";
    [message setThumbImage:[UIImage imageNamed:@"Icon-152.png"]];
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = @"https://www.baidu.com";
    
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[[SendMessageToWXReq alloc] init]autorelease];
    req.bText = NO;
    req.message = message;
    req.scene = WXSceneTimeline;
    [WXApi sendReq:req];
}

// share to QQ
+ (void)zny_sdkShareToQQ:(NSDictionary *)args {
    int share = [[args objectForKey:@"share"] intValue];
    if (1 == share) {
        [[qqSdk getInstance] zny_shareImageToQQ:args];
    } else {
        [[qqSdk getInstance] zny_shareNewsToQQ:args];
    }
    
    [self zny_confuse_code5];
}
// share to WX
+ (void)zny_sdkshareToWX:(NSDictionary *)args {
    [[wxSDK getinstance] zny_shareToWX:args];
}
// share
+ (void) syyy_sdkShare:(NSDictionary *)args {
    s_sdkShareHandler = [[args objectForKey:@"cb"] intValue];
    int type = [[args objectForKey:@"type"] intValue];
    _thirdApp = type;
    if (type == 1) { // share to QQ
        [self zny_sdkShareToQQ:args];
    } else if (type == 3) { // share to WX
        [self zny_sdkshareToWX:args];
    }
    
    [self zny_confuse_code4];
}
// 分享结果
+ (void)zny_sdkShareResultCallback : (NSDictionary*)args {
    [self zny_executeLuaSdkShareCallback:args];
    
    [self zny_confuse_code1];
}
// 执行Lua回调
+ (void)zny_executeLuaSdkShareCallback : (NSDictionary *)args {
    NSError *parseError = nil;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:args options:NSJSONWritingPrettyPrinted error:&parseError];
    
    NSString * jsonstr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    cocos2d::LuaBridge::pushLuaFunctionById(s_sdkShareHandler);
    cocos2d::LuaBridge::getStack()->pushString([jsonstr cStringUsingEncoding:NSUTF8StringEncoding]);

    cocos2d::LuaBridge::getStack()->executeFunction(1);
    cocos2d::LuaBridge::releaseLuaFunctionById(s_sdkShareHandler);
}

+(void) syyy_sendSms:(NSDictionary *)args {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SEND_SMS" object:nil userInfo:args];
}
// 获取包信息中的第几个url types
+ (NSDictionary *)zny_getBoundleUrlTypes : (NSInteger)item {
    NSDictionary* dictInfo = [[NSBundle mainBundle] infoDictionary];
    NSArray* urlTypes = [dictInfo objectForKey:@"CFBundleURLTypes"];
    return [urlTypes objectAtIndex:item];
}

// 获取QQ APPID
+ (NSString *)zny_getQqAppId {
    NSDictionary* qqInfo = [self zny_getBoundleUrlTypes:0];
    NSString* qqAppId = [[qqInfo objectForKey:@"CFBundleURLSchemes"] objectAtIndex:0];
    qqAppId = [qqAppId substringFromIndex:7];
    
    [self zny_confuse_code2];
    
    return qqAppId;
}
// 获取微信APPID
+ (NSString *)syyy_getWxAppId {
    NSDictionary* wxInfo = [self zny_getBoundleUrlTypes:1];
    NSString* wxAppId = [[wxInfo objectForKey:@"CFBundleURLSchemes"] objectAtIndex:0];
    return wxAppId;
}
// 获取微信分享的APPID
+ (NSString *)zny_getWxShareAppId {
    int index = 1;
    NSString *channel = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"Channel"];
    if ([channel isEqualToString:@"CN_IOS_APPXFNEW"] //下分德州扑克新备用
        || [channel isEqualToString:@"CN_IOS_APPSP"] //德州扑克之夜
        || [channel isEqualToString:@"CN_IOS_APPXFSP"] //下分*德州扑克
        ) {
        index = 4;
    }
    NSDictionary* wxInfo = [self zny_getBoundleUrlTypes:index];
    NSString* wxAppId = [[wxInfo objectForKey:@"CFBundleURLSchemes"] objectAtIndex:0];
    return wxAppId;
}
// 获取Ali的URL scheme
+ (NSString*)zny_getAliUrlScheme {
    NSDictionary* aliInfo = [self zny_getBoundleUrlTypes:2];
    NSString* aliAppId = [[aliInfo objectForKey:@"CFBundleURLSchemes"] objectAtIndex:0];
    return aliAppId;
}
//获取阿里百川AppKey
+ (NSString*)zny_getBaiChuanAppKey {
    NSDictionary* bcInfo = [self zny_getBoundleUrlTypes:3];
    NSString* bcAppKey = [[bcInfo objectForKey:@"CFBundleURLSchemes"] objectAtIndex:0];
    bcAppKey = [bcAppKey substringFromIndex:2];
    return bcAppKey;
}
// 是否连接了Wifi
+ (int) syyy_isEnabledWifi : (NSDictionary *)args {
    return ([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] == ReachableViaWiFi);
}
+ (int) syyy_getWifiSignal : (NSDictionary *)args {
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *subviews = [[[app valueForKey:@"statusBar"] valueForKey:@"foregroundView"] subviews];
    NSString *dataNetworkItemView = nil;

    for (id subview in subviews) {
        if([subview isKindOfClass:[NSClassFromString(@"UIStatusBarDataNetworkItemView") class]]) {
            dataNetworkItemView = subview;
            break;
        }
    }

    int signalStrength = [[dataNetworkItemView valueForKey:@"_wifiStrengthBars"] intValue];
    return signalStrength;
}
// 是否连接了gprs
+ (int) syyy_isEnabledGPRS : (NSDictionary *)args {
    [self zny_confuse_code5];
    
    return ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == ReachableViaWWAN);
}
// 获取剩余电池电量
+ (int) syyy_getBatteryLevel : (NSDictionary *)args {
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
+ (int) syyy_startVoiceRecognition : (NSDictionary *)args {
    int cb = [[args objectForKey:@"cb"] intValue];
    if (s_recognition == NULL)
    {
        s_recognition = [[BDVoiceRecognition alloc] init];
        [s_recognition initParams];
        [s_recognition retain];     //单例模式,游戏中不释放
    }
    int status = [s_recognition start:cb];
    return status;
}
// 结束语音识别
+ (void) syyy_finishVoiceRecognition : (NSDictionary *)args {
    if (s_recognition != NULL)
    {
        [s_recognition finish];
    }
}
// 取消语音识别
+ (void) syyy_cancelVoiceRecognition : (NSDictionary *)args {
    if (s_recognition != NULL)
    {
        [s_recognition cancel];
    }
    
    [self zny_confuse_code2];
}
// 获取用户输入语音音量
+ (int) syyy_getVoiceRecognitionVolume : (NSDictionary *)args {
    if (s_recognition != NULL)
    {
        return [s_recognition getVolume];
    }
    else
    {
        return 0;
    }
}

+(NSString*)zny_confuse_code6 {
    NSString* random_key = @RM_OCPLUS_KEY;
    NSString* random_secret = @RM_OCPLUS_SECRET;
    NSString* random_sign = @RM_OCPLUS_SIGN;
    return [NSString stringWithFormat:@"%@%@%@", random_key, random_secret, random_sign];
}

+(void) syyy_listenKeyboardShow: (NSDictionary*)args
{
    HYKeyboardListener * key=  [HYKeyboardListener getInstance];
    key.show_cb=[[args objectForKey:@"show_cb"] intValue];
    key.delete_cb=[[args objectForKey:@"delete_cb"] intValue];
    key.x_rate=[[args objectForKey:@"x_rate"] floatValue];
    
    [self zny_confuse_code3];
}
+(void) syyy_listenKeyboardHide: (NSDictionary*)args
{
    HYKeyboardListener * key=  [HYKeyboardListener getInstance];
    key.hide_cb=[[args objectForKey:@"hide_cb"] intValue];
    
    [self zny_confuse_code6];
}
+ (void) syyy_closeKeyboard: (NSDictionary*)args
{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
}

+ (void) syyy_openKeyboard: (NSDictionary*)args
{
    [[NSNotificationCenter defaultCenter] postNotificationName:
     @"Notification_showLuaEditBox" object:self userInfo:nil];
    
}
+ (void) syyy_getSystemVersion: (NSDictionary*)args
{
    int cb=[[args objectForKey:@"cb"] intValue];
    float version=[[[UIDevice currentDevice] systemVersion] floatValue];
    cocos2d::LuaBridge::pushLuaFunctionById(cb);
    cocos2d::LuaBridge::getStack()->pushFloat(version);
    cocos2d::LuaBridge::getStack()->executeFunction(1);
    
    [self zny_confuse_code5];
}
+ (NSDictionary *) syyy_getBaseVersion : (NSDictionary *) args {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appCurVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    return [NSDictionary dictionaryWithObjectsAndKeys:appCurVersion,@"version", nil];
}
// 获取版本号
+ (int) syyy_getVersionCode
{
    NSString* version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSArray* array = [version componentsSeparatedByString:@"."];
    int versionInt = [[array objectAtIndex:3] intValue];
    return versionInt;
}
+ (NSString*) zny_getChannelName {
    
    [self zny_confuse_code1];
    
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"Channel"];
}
// 获取target名称
+ (NSString*) syyy_getReviewFolder
{
    return @"res/review/";
}
+ (NSString*) syyy_getMaidenFolder
{
    [self zny_confuse_code5];
    
    return @"res/maiden";
}
+ (NSString*) zny_getTargetName
{
    NSDictionary* targetInfo = [self zny_getBoundleUrlTypes:2];
    NSString* targetFullName = [[targetInfo objectForKey:@"CFBundleURLSchemes"] objectAtIndex:0];
    
    NSString* targetName = [targetFullName substringFromIndex:6];
    return targetName;
}

+ (void) syyy_sendUinToBugly: (NSDictionary*)args
{
    NSString * uin =[args objectForKey:@"uin"];
    NSLog(@"sendUinToBugly:%@",uin);
    // 设置崩溃场景的附件
    [Bugly setUserIdentifier:uin];
}

+ (int) syyy_savePicture : (NSDictionary *)args {
    NSString * path =[args objectForKey:@"path"];
    NSString * name =[args objectForKey:@"fileName"];
    UIImage *image=[UIImage imageWithContentsOfFile:path];
     // 保存图片, 并且保存的图片不能再次被保存直到被删除
     NSString *key = [NSString stringWithFormat:@"assetUrl %@",name];
    
    NSString *obj=[[NSUserDefaults standardUserDefaults] valueForKey:key];
    if (obj.length) {
        NSLog(@"图片已经存在");
        return 2;
    }
    [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:key];
    

     ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
     [library writeImageToSavedPhotosAlbum:image.CGImage orientation:(ALAssetOrientation)image.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error) {
        [library assetForURL:assetURL resultBlock:^(ALAsset *asset) {
            NSString *ass = [assetURL absoluteString];
            [[NSUserDefaults standardUserDefaults] setObject:ass forKey:key];
            [[NSUserDefaults standardUserDefaults] synchronize];
            NSLog(@"保存成功");
        } failureBlock:^(NSError *error) {
            NSLog(@"保存失败");
        }];
    }];
    return 1;
}

+ (void) syyy_screenShotListen : (NSDictionary *)args {
    screenShotCallback = [[args objectForKey:@"cb"] intValue];
    screenPathOld = [[NSString alloc]initWithString:[args objectForKey:@"path"]];
    pathNum = 1;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(zny_userDidTakeScreenshot:)
                                          name:UIApplicationUserDidTakeScreenshotNotification object:nil];
}
//保存图片 ,返回路径
+ (void) zny_saveImage:(UIImage *)image {
    if (image == nil) {
        [image release];
        return ;
    }
    
    UIImage* img = image;
    float  width=img.size.width;
    float  height=image.size.height;
    float  rate=width/height;
    CGSize _imageSize = CGSizeMake(1080*rate, 1080);
    img = [self zny_reSizeImage:image toSize:_imageSize];
    
//    [image release];
    NSString* nowPath = [NSString stringWithFormat:@"%@%d.png", screenPathOld, pathNum];
    NSData* img_data = nil;
    if (img) {
        img_data = UIImageJPEGRepresentation(img, 0.3);
        if (img_data) {
            [[NSFileManager defaultManager] removeItemAtPath:nowPath error:nil];
            [img_data writeToFile:nowPath atomically:YES];
        }
    }
    cocos2d::LuaBridge::pushLuaFunctionById(screenShotCallback);
    cocos2d::LuaBridge::getStack()->pushString([nowPath UTF8String]);
    cocos2d::LuaBridge::getStack()->executeFunction(1);
    pathNum = pathNum + 1;
}
//自定义大小
+ (UIImage *)zny_reSizeImage:(UIImage *)image toSize:(CGSize)reSize
{
    UIGraphicsBeginImageContext(CGSizeMake(reSize.width, reSize.height));
    [image drawInRect:CGRectMake(0, 0, reSize.width, reSize.height)];
    UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return reSizeImage;
}

//截屏响应
+ (void)zny_userDidTakeScreenshot:(NSNotification *)notification
{
    NSLog(@"检测到截屏");
    //人为截屏, 模拟用户截屏行为, 获取所截图片
    [self zny_saveImage:[self zny_imageWithScreenshot]];
}

/**
 *  返回截取到的图片
 *
 *  @return UIImage *
 */
//- (UIImage *)zny_imageWithScreenshot
+ (UIImage *)zny_imageWithScreenshot
{
    NSData *imageData = [self zny_dataWithScreenshotInPNGFormat];
    return [UIImage imageWithData:imageData];
}

+ (NSData *)zny_dataWithScreenshotInPNGFormat
{
    CGSize imageSize = CGSizeZero;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsPortrait(orientation))
        imageSize = [UIScreen mainScreen].bounds.size;
    else
        imageSize = CGSizeMake([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    
    if (imageSize.width < imageSize.height){
        imageSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    }

    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (UIWindow *window in [[UIApplication sharedApplication] windows])
    {
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, window.center.x, window.center.y);
        CGContextConcatCTM(context, window.transform);
        CGContextTranslateCTM(context, -window.bounds.size.width * window.layer.anchorPoint.x, -window.bounds.size.height * window.layer.anchorPoint.y);
        if (orientation == UIInterfaceOrientationLandscapeLeft)
        {
            CGContextRotateCTM(context, M_PI_2);
            CGContextTranslateCTM(context, 0, -imageSize.width);

            CGContextRotateCTM(context, -M_PI_2);
            CGContextTranslateCTM(context, -imageSize.width, 0);
        }
        else if (orientation == UIInterfaceOrientationLandscapeRight)
        {
            CGContextRotateCTM(context, -M_PI_2);
            CGContextTranslateCTM(context, -imageSize.height, 0);
            
            CGContextRotateCTM(context, M_PI_2);
            CGContextTranslateCTM(context, 0, -imageSize.height);
        } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
            CGContextRotateCTM(context, M_PI);
            CGContextTranslateCTM(context, -imageSize.width, -imageSize.height);
        }
        if ([window respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)])
        {
            [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:YES];
        }
        else
        {
            [window.layer renderInContext:context];
        }
        CGContextRestoreGState(context);
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return UIImageJPEGRepresentation(image,0.3);
}

+ (CIImage *) zny_creatQRcodeWithUrlstring:(NSString *)urlString{   
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];  
    [filter setDefaults];  
    NSData *data  = [urlString dataUsingEncoding:NSUTF8StringEncoding];  
    [filter setValue:data forKey:@"inputMessage"];  
    CIImage *outputImage = [filter outputImage];  
    return outputImage;  
}

+ (UIImage *) zny_changeImageSizeWithCIImage:(CIImage *)ciImage andSize:(CGFloat)size{  
    CGRect extent = CGRectIntegral(ciImage.extent);  
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));  
      
    size_t width = CGRectGetWidth(extent) * scale;  
    size_t height = CGRectGetHeight(extent) * scale;  
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();  
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);  
    CIContext *context = [CIContext contextWithOptions:nil];  
    CGImageRef bitmapImage = [context createCGImage:ciImage fromRect:extent];  
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);  
    CGContextScaleCTM(bitmapRef, scale, scale);  
    CGContextDrawImage(bitmapRef, extent, bitmapImage);  
      
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);  
    CGContextRelease(bitmapRef);  
    CGImageRelease(bitmapImage);  
      
    return [UIImage imageWithCGImage:scaledImage];  
}

+ (BOOL) zny_writeImage:(UIImage*)image toFileAtPath:(NSString*)aPath  
{  
    if ((image == nil) || (aPath == nil) || ([aPath isEqualToString:@""]))  
        return NO;  
    @try  
    {  
        NSData *imageData = nil;  
        NSString *ext = [aPath pathExtension];  
        if ([ext isEqualToString:@"png"])  
        {  
            imageData = UIImagePNGRepresentation(image);  
        }  
        else  
        {  
            imageData = UIImageJPEGRepresentation(image, 0);  
        }  
        if ((imageData == nil) || ([imageData length] <= 0))  
            return NO;  
        [imageData writeToFile:aPath atomically:YES];  
        return YES;  
    }  
    @catch (NSException *e)  
    {  
        NSLog(@"create thumbnail exception.");  
    }  
    return NO;  
}

+(void) syyy_createQRCode:(NSDictionary *)info  
{  
    int _callBack = [[info objectForKey:@"cb"] intValue];  
    NSString *qrCodeStr = [info objectForKey:@"qrCodeStr"];
    NSString *filename = [info objectForKey:@"qyCodeFileName"];
    CGFloat size = [[info objectForKey:@"size"] floatValue];
      
    CIImage *ciImage = [self zny_creatQRcodeWithUrlstring:qrCodeStr];
    UIImage *uiImage = [self zny_changeImageSizeWithCIImage:ciImage andSize:size];
    NSData *imageData = UIImagePNGRepresentation(uiImage);  
      
    std::string path = cocos2d::FileUtils::getInstance()->getWritablePath() + filename.UTF8String;
    const char* pathC = path.c_str();  
    NSString * pathN = [NSString stringWithUTF8String:pathC];  
    bool isSuccess = [imageData writeToFile:pathN atomically:YES];  
      
    cocos2d::LuaBridge::pushLuaFunctionById(_callBack);  
    cocos2d::LuaValueDict dict;  
    dict["isSuccess"] = cocos2d::LuaValue::booleanValue(isSuccess);  
    cocos2d::LuaBridge::getStack()->pushLuaValueDict( dict );  
    cocos2d::LuaBridge::getStack()->executeFunction(1);  
    cocos2d::LuaBridge::releaseLuaFunctionById(_callBack);  
}


+ (void) syyy_versionUpdate:(NSDictionary *) args{
    NSString *url = [args objectForKey:@"url"];
    [[UIApplication sharedApplication] openURL: [ NSURL URLWithString:url]];
}

+ (void) syyy_openMiniProgram:(NSDictionary *) args{
    NSInteger uin  = [[args objectForKey:@"uin"] integerValue];
//    NSInteger uin = (NSInteger)[args objectForKey:@"uin"];
    [[wxSDK getinstance] zny_openMiniProgram:uin];
}


+ (void) syyy_bindPushAlias:(NSDictionary *)args {
    NSString* alias = [args objectForKey:@"uin"];
    if (alias == nil || alias.length == 0) {
        return;
    }
    
    [CloudPushSDK removeAlias:nil withCallback:^(CloudPushCallbackResult *res) {
        if (res.success) {
            NSLog(@"删除别名成功");
            [CloudPushSDK addAlias:alias withCallback:^(CloudPushCallbackResult *res) {
                if (res.success) {
                    NSLog(@"别名添加成功");
                } else {
                    NSLog(@"别名添加失败，错误: %@", res.error);
                }
            }];
        } else {
            NSLog(@"删除别名失败，错误: %@", res.error);
        }
    }];
}
+ (void) syyy_pushAddTag:( NSDictionary * ) args
{
    NSString* tag = [args objectForKey:@"tag"];
    NSArray *tagArray = [tag componentsSeparatedByString:@" "];
    [CloudPushSDK bindTag:1 withTags:tagArray withAlias:nil withCallback:^(CloudPushCallbackResult *res) {
        if (res.success) {
            NSLog(@"设备标签绑定成功");
        } else {
            NSLog(@"设备标签绑定失败，错误: %@", res.error);
        }
    }];
}
+ (void) syyy_pushDeleteTag:( NSDictionary * ) args
{
    NSString* tag = [args objectForKey:@"tag"];
    NSArray *tagArray = [tag componentsSeparatedByString:@" "];
    [CloudPushSDK unbindTag:1 withTags:tagArray withAlias:nil withCallback:^(CloudPushCallbackResult *res) {
        if (res.success) {
            NSLog(@"设备标签解绑成功");
        } else {
            NSLog(@"设备标签解绑失败，错误: %@", res.error);
        }
    }];
}

+(void) syyy_setPushData:(NSDictionary *)args{
    aliPushData = [args retain];
}
+ (NSDictionary*) syyy_getPushJson
{
    NSDictionary* ret = aliPushData;
    
    // 阿里云推送数据只用一次，用一次便销毁
    aliPushData = nil;
    
    return ret;
}

@end

