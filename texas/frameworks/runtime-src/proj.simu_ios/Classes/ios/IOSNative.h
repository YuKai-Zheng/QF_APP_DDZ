//
//  IOSNative.h
//  texas
//
//  Created by qf on 14-11-18.
//
//

#ifndef texas_IOSNative_h
#define texas_IOSNative_h


#import <UIKit/UIKit.h>
#import "IOSMacro.h"

static int loginCallback;
static int sharePicLuaCallBack;
static int s_BindingCallback;

@interface IOSNative : NSObject {
    
}

+ (NSDictionary *) getBaseVersion: (NSDictionary *) args;


+ (void) takePhoto : (NSDictionary * ) args;
+ (void) selectPhoto :(NSDictionary * ) args;
+ (void) beforePhoto :(NSDictionary *) args;
+ (void) umengStatistics : (NSDictionary *) args;
+ (void) playVibrate : (NSDictionary *) args;
+ (void) requestApplyAuth :(NSDictionary * ) args;

+ (NSDictionary *)  getRegInfo : (NSDictionary *) args;
+ (NSString *) getKey : (NSDictionary *)args;
+ (NSDictionary *) initWxAndQQShow ;
+ (NSString * ) MD5 :(NSString * ) input ;
+ (NSString *) getLang : (NSDictionary * ) args;

+ (void) showWebView   : ( NSDictionary * ) args;
+ (void) removeWebView : ( NSDictionary * ) args;

+ (void) bindJpushAlias:( NSDictionary * ) args;
+ (void) jpushAddTag:( NSDictionary * ) args;
+ (void) jpushDeleteTag:( NSDictionary * ) args;

+ (void) sdkAccountLogin : ( NSDictionary * ) args;
+ (void) removeDir: (NSDictionary * ) args;
+ (void) sharePic : (NSDictionary * ) args;
+ (void) sharePicCallBack : (int) successed;

+ (void) sdkShare : (NSDictionary *)args;

+ (void) init;

+ (void) sdkAccountLoginSuccess:(NSDictionary *)args;
+ (void) qqLoginSuccess;
+ (void) qqLoginFailed;
+(void) uploadError : (NSDictionary *) args;
+(void) feedBack : (NSDictionary *) args;
+(int) getLoginType;
// -- pay
+(void) initPay ;
+(void) pay : (NSDictionary *) args;  // lua 端调用 pay

+(NSDictionary *) payCallback : (NSDictionary *) args; //回调参数给 lua
+(void)handleOpenurl:(NSURL *) url; //注册url

//
+(UIViewController *) getRootController;//获取当前根viewcontroller
+(void) wxGetCodeSuccess:(NSDictionary *)args;


+(int) isSmsVerificationEnabled : (NSDictionary *)args;
+(void) getSmsVerificationCode : (NSDictionary *)args;
+(void) getVoiceVerificationCode : (NSDictionary *)args;

//david

+ (void) shareToWeixinForIOS;

+ (void)sdkShareResultCallback : (NSDictionary*)args;

+ (NSDictionary *)getBoundleUrlTypes : (NSInteger)item;
+ (NSString*)getQqAppId;
+ (NSString*)getWxAppId;
// + (NSString*)getWxSecret;
+ (NSString*)getAliUrlScheme;
+ (void) listenKeyboardShow: (NSDictionary*)args;
+ (void) listenKeyboardHide: (NSDictionary*)args;
+ (void) closeKeyboard: (NSDictionary*)args;
+ (void) getIosVersion: (NSDictionary*)args;

+ (int) isEnabledWifi : (NSDictionary *)args;
+ (int) isEnabledGPRS : (NSDictionary *)args;
+ (int) getBatteryLevel : (NSDictionary *)args;
+ (int) startSpeachToText : (NSDictionary *)args;
+ (void) finishVoiceRecognition : (NSDictionary *)args;
+ (void) cancelVoiceRecognition : (NSDictionary *)args;
+ (int) getVoiceRecognitionVolume : (NSDictionary *)args;


+ (void) openKeyboard: (NSDictionary*)args;

//talkingdata

+ (void) td_onRegister:(NSDictionary *)args;

+ (void) td_onLogin:(NSDictionary *)args;

+ (void) td_onPay:(NSString *)userId withOrderId:(NSString *)orderId withAmount:(int)amount withCurrencyType:(NSString *)currencyType withPayType:(NSString *)payType;
+ (void) sendUinToBugly: (NSDictionary*)args;

+ (void) haimaLogin : ( NSDictionary * ) args;
+ (void) haimaLoginCallback : (NSString *)userId Token:(NSString *)token;
@end


#endif
