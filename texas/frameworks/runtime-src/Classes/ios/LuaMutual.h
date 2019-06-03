//
//  LuaMutual.h
//  texas
//
//  Created by qf on 14-11-18.
//
//

#ifndef __LUAMUTUAL_H_821509__
#define __LUAMUTUAL_H_821509__


#import <UIKit/UIKit.h>
#import "IOSMacro.h"

static int loginCallback;
static int sharePicLuaCallBack;
static int s_BindingCallback;
static int xyloginOutCallback;
static int screenShotCallback;
static int pathNum;
static NSString* screenPathOld;
static NSDictionary* aliPushData=nil;

@interface LuaMutual : NSObject {
    
}

+ (void) zny_beforePhoto :(NSDictionary *) args;
+ (void) syyy_removeDir: (NSDictionary * ) args;
+ (void) zny_sharePicCallBack : (int) successed;


+ (NSDictionary *)syyy_getBaseVersion: (NSDictionary *) args;
+ (void) syyy_getSystemVersion: (NSDictionary*)args;
+ (int) syyy_getVersionCode;

+ (void) syyy_takePhoto : (NSDictionary * ) args;
+ (void) syyy_selectPhoto :(NSDictionary * ) args;

+ (void) syyy_umengStatistics : (NSDictionary *) args;
+ (void) syyy_playVibrate : (NSDictionary *) args;
+ (void) syyy_requestApplyAuth :(NSDictionary * ) args;
+ (NSString *) syyy_getIDFA;
+ (NSString *) syyy_getGameName;
+ (NSDictionary *) syyy_getRegInfo : (NSDictionary *) args;
+ (NSString *) syyy_getKey;

+ (NSString * ) zny_MD5 :(NSString * ) input ;
+ (NSString *) syyy_getLang : (NSDictionary *)args;

+ (void) syyy_showWebView : ( NSDictionary * ) args;
+ (void) syyy_removeWebView;

+ (NSDictionary *) syyy_initWxAndQQShow : (NSDictionary *) args;
+ (void) syyy_sdkAccountLogin : ( NSDictionary * ) args;
+ (void) syyy_sharePic : (NSDictionary * ) args;
+ (void) syyy_sdkShare : (NSDictionary *)args;
+ (void) init;
+(void) syyy_uploadError : (NSDictionary *) args;

+ (void) zny_sdkAccountLoginSuccess:(NSDictionary *)args;
+ (void) zny_qqLoginSuccess;
+ (void) zny_qqLoginFailed;
+(int) zny_getLoginType;
+(int) zny_getThirdAppType;
+ (void) syyy_shareToWeixinForIOS;
+ (void)zny_sdkShareResultCallback : (NSDictionary*)args;
+(void) zny_wxGetCodeSuccess:(NSDictionary *)args;
+ (NSString*)zny_getQqAppId;
+ (NSString*)syyy_getWxAppId;
+ (NSString*)zny_getWxShareAppId;
+ (void)zny_executeLuaSdkShareCallback : (NSDictionary *)args;
+ (void)zny_sdkshareToWX:(NSDictionary *)args;
+ (void)zny_sdkShareToQQ:(NSDictionary *)args;

+(void) zny_initBCFeedback; //阿里百川反馈初始化
+(void) syyy_AlibaichuanUnreadRequst: (NSDictionary *)args;
+(void) syyy_feedBack : (NSDictionary *) args;
+ (NSString*)zny_getBaiChuanAppKey;

// -- pay
+(void) zny_initParty;
+(void) syyy_party : (NSDictionary *) args;  // lua 端调用 pay
+(NSDictionary *) zny_partyCallback : (NSDictionary *) args; //回调参数给 lua
+(void)handleOpenurl:(NSURL *) url; //注册url

//
+(UIViewController *) getRootController;//获取当前根viewcontroller

// 短信验证
+(int) syyy_isSmsVerificationEnabled : (NSDictionary *)args;
+(void) syyy_getSmsVerificationCode : (NSDictionary *)args;
+(void) syyy_getVoiceVerificationCode : (NSDictionary *)args;


+ (NSDictionary *)zny_getBoundleUrlTypes : (NSInteger)item;

// + (NSString*)getWxSecret;
+ (NSString*)zny_getAliUrlScheme;
+ (CGRect) zny_getScreenFrame;
+ (bool) syyy_getIfScreenFrame;
// 输入框
+ (void) syyy_listenKeyboardShow: (NSDictionary*)args;
+ (void) syyy_listenKeyboardHide: (NSDictionary*)args;
+ (void) syyy_closeKeyboard: (NSDictionary*)args;
+ (void) syyy_openKeyboard: (NSDictionary*)args;

+ (NSString*) syyy_getReviewFolder;
+ (NSString*) syyy_getMaidenFolder;
+ (NSString*) zny_getTargetName;
+ (NSString*) zny_getChannelName;

+ (int) syyy_isEnabledWifi : (NSDictionary *)args;
+ (int) syyy_getWifiSignal : (NSDictionary *)args;
+ (int) syyy_isEnabledGPRS : (NSDictionary *)args;
+ (int) syyy_getBatteryLevel : (NSDictionary *)args;

//语音识别
+ (int) syyy_startVoiceRecognition : (NSDictionary *)args;
+ (void) syyy_finishVoiceRecognition : (NSDictionary *)args;
+ (void) syyy_cancelVoiceRecognition : (NSDictionary *)args;
+ (int) syyy_getVoiceRecognitionVolume : (NSDictionary *)args;

+ (void) syyy_sendUinToBugly: (NSDictionary*)args;
+ (void) syyy_sendSms:(NSDictionary *)args;

+(int) syyy_savePicture : ( NSDictionary * ) args;
+ (void) syyy_screenShotListen : ( NSDictionary * ) args;
+ (void)zny_userDidTakeScreenshot:(NSNotification *)notification;
+(UIImage *)zny_imageWithScreenshot;
+ (NSData *)zny_dataWithScreenshotInPNGFormat;
+ (void) zny_saveImage:(UIImage *)image;
+ (UIImage *)zny_reSizeImage:(UIImage *)image toSize:(CGSize)reSize;

+ (void) syyy_createQRCode:(NSDictionary *)info;

+ (void) syyy_versionUpdate:(NSDictionary *) args;
+ (void) syyy_openMiniProgram:(NSDictionary *) args;

//阿里云推送相关
+(void) syyy_aliPush:(NSDictionary *)args;
+(void) syyy_setPushData:(NSDictionary *)args;
+(void) syyy_bindPushAlias:(NSDictionary *)args;
+ (void) syyy_pushAddTag:( NSDictionary * ) args;
+ (void) syyy_pushDeleteTag:( NSDictionary * ) args;
+ (NSDictionary*) syyy_getPushJson;

//+ (void) syyy_bindJpushAlias:( NSDictionary * ) args;
//+ (void) syyy_jpushAddTag:( NSDictionary * ) args;
//+ (void) syyy_jpushDeleteTag:( NSDictionary * ) args;


@end

#endif
