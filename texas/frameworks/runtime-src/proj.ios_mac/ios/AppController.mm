/****************************************************************************
 Copyright (c) 2010-2013 cocos2d-x.org
 Copyright (c) 2013-2014 Chukong Technologies Inc.

 http://www.cocos2d-x.org

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/
#import "IOSMacro.h"
#import <UIKit/UIKit.h>
#import "cocos2d.h"
#include "SimpleAudioEngine.h"

#import "AppController.h"
#import "AppDelegate.h"
#import "RootViewController.h"
#import "CCEAGLView.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import "LuaMutual.h"
#import "wxSDK.h"
#import "qqSdk.h"
#if SDK_ACCOUNT == SDK_FACEBOOK_ACCOUNT
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#endif

#include "ConfigParser.h"
#include "qf/QNative.h"
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

#import "UMMobClick/MobClick.h"

#import "Reachability.h"
#include "script_ferry/ScriptFerry.h"

//#import "TalkingDataAppCpa.h"
#import <Bugly/BuglyLog.h>
#import <Bugly/Bugly.h>
#include "HYSMSVerification.h"

//#ifdef SDK_XYPLATFORM
//#import <XYPlatform/XYPlatform.h>
//#endif

//#import "AutoCaller.h"

@interface AppController ()<UNUserNotificationCenterDelegate>
@end

@implementation AppController{
        // iOS 10通知中心
        UNUserNotificationCenter *_notificationCenter;
}

#pragma mark -
#pragma mark Application lifecycle

// cocos2d application instance
static AppDelegate s_sharedApplication;
static int s_tag_call_back = 0; //打电话回来：0打电话回来 1从后台切入前台


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    ConfigParser::getInstance()->readConfig();
    
    CGRect frame = [LuaMutual zny_getScreenFrame];
    // Add the view controller's view to the window and display.
    window = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
    CCEAGLView *eaglView = [CCEAGLView viewWithFrame: frame
                                     pixelFormat: kEAGLColorFormatRGBA8
                                     depthFormat: GL_DEPTH24_STENCIL8_OES
                              preserveBackbuffer: NO
                                      sharegroup: nil
                                   multiSampling: NO
                                 numberOfSamples: 0 ];

    [eaglView setMultipleTouchEnabled:NO];
    
    // Use RootViewController manage CCEAGLView
    viewController = [[RootViewController alloc] initWithNibName:nil bundle:nil];
    //viewController.wantsFullScreenLayout = YES;
    viewController.view = eaglView;

    // Set RootViewController to window
    if ( [[UIDevice currentDevice].systemVersion floatValue] < 6.0)
    {
        // warning: addSubView doesn't work on iOS6
        [window addSubview: viewController.view];
    }
    else
    {
        // use this method on ios6
        [window setRootViewController:viewController];
    }

    [window makeKeyAndVisible];

    //MOB短信验证
//    NSString *  smsAppID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"MobSMSAppID"];
//    NSString *  smsSecret = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"MobSMSSecret"];
//    [HYSMSVerification zny_initWithKey:smsAppID AndSecret:smsSecret];
    
    [[UIApplication sharedApplication] setStatusBarHidden: YES];

    // IMPORTANT: Setting the GLView should be done after creating the RootViewController
    cocos2d::GLView *glview = cocos2d::GLView::createWithEAGLView(eaglView);
    cocos2d::Director::getInstance()->setOpenGLView(glview);
    

    cocos2d::Application::getInstance()->run();
    [LuaMutual init];
    
    // APNs注册，获取deviceToken并上报
    [self registerAPNS:application];
    //阿里云推送
    [self zny_pushInit:launchOptions];
    // 监听推送通道打开动作
    [self listenerOnChannelOpened];
    // 监听推送消息到达
    [self registerMessageReceive];
    // 点击通知将App从关闭状态启动时，将通知打开回执上报
    
    
    //这里初始化支付相关的
    [LuaMutual zny_initParty];
    //初始化阿里百川反馈
    [LuaMutual zny_initBCFeedback];
    [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
    //Umeng初始化
    [self zny_umengInit];

    //微信注册
   [WXApi registerApp:[LuaMutual syyy_getWxAppId] enableMTA:false];
   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(zny_sendSms:) name: @"SEND_SMS" object:nil];
    
     //AutoCaller* caller = [[AutoCaller alloc] init];
     //[caller callAll];
    
    //@tomas 2017-5-12
    //去掉网络变化的监听
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
//    Reachability *hostReach = [Reachability reachabilityWithHostname:@"www.baidu.com"];
//    [hostReach startNotifier];
    
//    NSString *  TalkingData = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"TalkingData"] ;
    
//    if (TalkingData != nil && [TalkingData isEqualToString:@""] == NO)
//    {
//        [TalkingDataAppCpa init:TalkingData withChannelId:@"AppStore"];
//    }
   [self zny_customizeBuglySDKConfig];
   [self zny_confuse_code1];
    
    return YES;
}

-(NSString*)zny_confuse_code1 {
    NSString* random_key = @RM_LUA_KEY;
    NSString* random_secret = @RM_LUA_SECRET;
    NSString* random_sign = @RM_LUA_SIGN;
    return [NSString stringWithFormat:@"%@%@%@", random_key, random_secret, random_sign];
}

// 自定义Bugly配置
- (void)zny_customizeBuglySDKConfig {
    BuglyConfig *config = [[BuglyConfig alloc] init];
    // 调试阶段开启sdk日志打印, 发布阶段请务必关闭
    #if DEBUG == 1
        config.debugMode = YES;
    #endif
    [BuglyLog initLogger:BuglyLogLevelDebug consolePrint:YES];

    NSDictionary* dictInfo = [[NSBundle mainBundle] infoDictionary];
    // 如果你的App有对应的发布渠道(如AppStore),你可以通过此接口设置, 默认值为unknown,
    config.channel = [dictInfo objectForKey:@"Channel"];
    NSString* BuglyAppId = [dictInfo objectForKey:@"BuglyAppId"];

    [Bugly startWithAppId:BuglyAppId config:config];
    
    [self zny_confuse_code13];
}

-(NSString*)zny_confuse_code2 {
    NSString* random_key = @RM_OC_KEY;
    NSString* random_secret = @RM_OC_SECRET;
    NSString* random_sign = @RM_OC_SIGN;
    return [NSString stringWithFormat:@"%@%@%@", random_key, random_secret, random_sign];
}

//@tomas 2017-5-12
//去掉网络变化的监听
//- (void)reachabilityChanged:(NSNotification *)note{
//    Reachability *reach = [note object];
//    NSParameterAssert([reach isKindOfClass:[Reachability class]]);
//    NetworkStatus status = [reach currentReachabilityStatus];
//    //NSLog(@"%d",status);
//    
//    if (status == NotReachable) {
//        if (ferry::ScriptFerry::getInstance()->isConnected()) {
//            ferry::ScriptFerry::getInstance()->disconnect();
//        }
//    }
//}

//Umeng SDk初始化
- (void)zny_umengInit {
    UMConfigInstance.channelId = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"Channel"];
    UMConfigInstance.appKey = @"5b2b1220f29d98386b000013";
    UMConfigInstance.bCrashReportEnabled = NO;
    UMConfigInstance.eSType = E_UM_GAME;
    UMConfigInstance.ePolicy = BATCH;
    [MobClick setLogEnabled:YES];
    [MobClick setAppVersion:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
    [MobClick startWithConfigure:UMConfigInstance];
    
    [self zny_confuse_code15];
}

- (void) zny_pushInit : (NSDictionary *)launchOptions {
//    NSDictionary* dictInfo = [[NSBundle mainBundle] infoDictionary];
//    NSString* alipush_appkey = [dictInfo objectForKey:@"AlipushAppKey"];
//    NSString* alipush_secret = [dictInfo objectForKey:@"AlipushSecret"];
    [CloudPushSDK autoInit:^(CloudPushCallbackResult *res) {
        if (res.success) {
            NSLog(@"Push SDK init success, deviceId: %@.", [CloudPushSDK getDeviceId]);
        } else {
            NSLog(@"Push SDK init failed, error: %@", res.error);
        }
    }];
    
    [CloudPushSDK sendNotificationAck:launchOptions];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 10;
}

-(NSString*)zny_confuse_code13 {
    NSString* random_key = @RM_OCPLUS_KEY;
    NSString* random_secret = @RM_OCPLUS_SECRET;
    NSString* random_sign = @RM_OCPLUS_SIGN;
    return [NSString stringWithFormat:@"%@%@%@", random_key, random_secret, random_sign];
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    // Required
    [CloudPushSDK registerDevice:deviceToken withCallback:^(CloudPushCallbackResult *res) {
        if (res.success) {
            NSLog(@"Register deviceToken success. = %@",deviceToken);
        } else {
            NSLog(@"Register deviceToken failed, error: %@", res.error);
        }
    }];
}

#pragma mark Notification Open
/*
 *  App处于启动状态时，通知打开回调
 */
- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo {
    NSLog(@"Receive one notification.");
    // 取得APNS通知内容
//    NSDictionary *aps = [userInfo valueForKey:@"aps"];
//    // 内容
//    NSString *content = [aps valueForKey:@"alert"];
//    // badge数量
//    NSInteger badge = [[aps valueForKey:@"badge"] integerValue];
//    // 播放声音
//    NSString *sound = [aps valueForKey:@"sound"];
//    // 取得通知自定义字段内容，例：获取key为"Extras"的内容
//    NSString *Extras = [userInfo valueForKey:@"Extras"]; //服务端中Extras字段，key是自己定义的
//    NSLog(@"content = [%@], badge = [%ld], sound = [%@], Extras = [%@]", content, (long)badge, sound, Extras);
//    // iOS badge 清0
//    application.applicationIconBadgeNumber = 0;
//    // 同步通知角标数到服务端
//    // [self syncBadgeNum:0];
//    // 通知打开回执上报
//    // [CloudPushSDK handleReceiveRemoteNotification:userInfo];(Deprecated from v1.8.1)
//    [CloudPushSDK sendNotificationAck:userInfo];
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    [self zny_confuse_code13];
    
    // 取得APNS通知内容
//    NSDictionary *aps = [userInfo valueForKey:@"aps"];
//    // 内容
//    NSString *content = [aps valueForKey:@"alert"];
//    // badge数量
//    NSInteger badge = [[aps valueForKey:@"badge"] integerValue];
//    // 播放声音
//    NSString *sound = [aps valueForKey:@"sound"];
//    // 取得通知自定义字段内容，例：获取key为"Extras"的内容
//    NSString *Extras = [userInfo valueForKey:@"Extras"]; //服务端中Extras字段，key是自己定义的
//    NSLog(@"content = [%@], badge = [%ld], sound = [%@], Extras = [%@]", content, (long)badge, sound, Extras);
//    // iOS badge 清0
//    application.applicationIconBadgeNumber = 0;
//    // 同步通知角标数到服务端
//     [self syncBadgeNum:0];
//    // 通知打开回执上报
//    // [CloudPushSDK handleReceiveRemoteNotification:userInfo];(Deprecated from v1.8.1)
//    [CloudPushSDK sendNotificationAck:userInfo];
}

-(NSString*)zny_confuse_code14 {
    NSString* random_key = @RM_TEXAS_KEY;
    NSString* random_secret = @RM_TEXAS_SECRET;
    NSString* random_sign = @RM_TEXAS_SIGN;
    return [NSString stringWithFormat:@"%@%@%@", random_key, random_secret, random_sign];
}

#pragma mark SDK Init
- (void)initCloudPush {
    // 正式上线建议关闭
    [CloudPushSDK turnOnDebug];
    // SDK初始化，手动输出appKey和appSecret
    //    [CloudPushSDK asyncInit:testAppKey appSecret:testAppSecret callback:^(CloudPushCallbackResult *res) {
    //        if (res.success) {
    //            NSLog(@"Push SDK init success, deviceId: %@.", [CloudPushSDK getDeviceId]);
    //        } else {
    //            NSLog(@"Push SDK init failed, error: %@", res.error);
    //        }
    //    }];
    
    // SDK初始化，无需输入配置信息
    // 请从控制台下载AliyunEmasServices-Info.plist配置文件，并正确拖入工程
    [CloudPushSDK autoInit:^(CloudPushCallbackResult *res) {
        if (res.success) {
            NSLog(@"Push SDK init success, deviceId: %@.", [CloudPushSDK getDeviceId]);
        } else {
            NSLog(@"Push SDK init failed, error: %@", res.error);
        }
    }];
}

#pragma mark APNs Register
/**
 *    向APNs注册，获取deviceToken用于推送
 *
 *    @param     application
 */
- (void)registerAPNS:(UIApplication *)application {
    float systemVersionNum = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (systemVersionNum >= 10.0) {
        // iOS 10 notifications
        _notificationCenter = [UNUserNotificationCenter currentNotificationCenter];
        // 创建category，并注册到通知中心
        [self createCustomNotificationCategory];
        _notificationCenter.delegate = self;
        // 请求推送权限
        [_notificationCenter requestAuthorizationWithOptions:UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                // granted
                NSLog(@"User authored notification.");
                // 向APNs注册，获取deviceToken
                dispatch_async(dispatch_get_main_queue(), ^{
                    [application registerForRemoteNotifications];
                });
            } else {
                // not granted
                NSLog(@"User denied notification.");
            }
        }];
    } else if (systemVersionNum >= 8.0) {
        // iOS 8 Notifications
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
        [application registerUserNotificationSettings:
         [UIUserNotificationSettings settingsForTypes:
          (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge)
                                           categories:nil]];
        [application registerForRemoteNotifications];
#pragma clang diagnostic pop
    } else {
        // iOS < 8 Notifications
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
#pragma clang diagnostic pop
    }
}

/**
 *  主动获取设备通知是否授权(iOS 10+)
 */
- (void)getNotificationSettingStatus {
    [_notificationCenter getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        if (settings.authorizationStatus == UNAuthorizationStatusAuthorized) {
            NSLog(@"User authed.");
        } else {
            NSLog(@"User denied.");
        }
    }];
}

/**
 *  创建并注册通知category(iOS 10+)
 */
- (void)createCustomNotificationCategory {
    // 自定义`action1`和`action2`
    UNNotificationAction *action1 = [UNNotificationAction actionWithIdentifier:@"action1" title:@"test1" options: UNNotificationActionOptionNone];
    UNNotificationAction *action2 = [UNNotificationAction actionWithIdentifier:@"action2" title:@"test2" options: UNNotificationActionOptionNone];
    // 创建id为`test_category`的category，并注册两个action到category
    // UNNotificationCategoryOptionCustomDismissAction表明可以触发通知的dismiss回调
    UNNotificationCategory *category = [UNNotificationCategory categoryWithIdentifier:@"test_category" actions:@[action1, action2] intentIdentifiers:@[] options:
                                        UNNotificationCategoryOptionCustomDismissAction];
    // 注册category到通知中心
    [_notificationCenter setNotificationCategories:[NSSet setWithObjects:category, nil]];
}


#pragma mark Channel Opened
/**
 *    注册推送通道打开监听
 */
- (void)listenerOnChannelOpened {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onChannelOpened:)
                                                 name:@"CCPDidChannelConnectedSuccess"
                                               object:nil];
}

/**
 *    推送通道打开回调
 *
 *    @param     notification
 */
- (void)onChannelOpened:(NSNotification *)notification {
//    [MsgToolBox showAlert:@"温馨提示" content:@"消息通道建立成功"];
    NSLog(@"消息通道建立成功");
}

#pragma mark Receive Message
/**
 *    @brief    注册推送消息到来监听
 */
- (void)registerMessageReceive {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onMessageReceived:)
                                                 name:@"CCPDidReceiveMessageNotification"
                                               object:nil];
}

/**
 *    处理到来推送消息
 *
 *    @param     notification
 */
- (void)onMessageReceived:(NSNotification *)notification {
    NSLog(@"Receive one message!");
    
    //fbe9c10a91a549ca92a183e0de7b9556
    CCPSysMessage *message = [notification object];
    NSString *title = [[NSString alloc] initWithData:message.title encoding:NSUTF8StringEncoding];
    NSString *body = [[NSString alloc] initWithData:message.body encoding:NSUTF8StringEncoding];
    NSLog(@"Receive message title: %@, content: %@.", title, body);
}

/* 同步通知角标数到服务端 */
- (void)syncBadgeNum:(NSUInteger)badgeNum {
    [CloudPushSDK syncBadgeNum:badgeNum withCallback:^(CloudPushCallbackResult *res) {
        if (res.success) {
            NSLog(@"Sync badge num: [%lu] success.", (unsigned long)badgeNum);
        } else {
            NSLog(@"Sync badge num: [%lu] failed, error: %@", (unsigned long)badgeNum, res.error);
        }
    }];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    //Optional
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    cocos2d::Director::getInstance()->pause();
    
    [self zny_confuse_code15];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    cocos2d::Director::getInstance()->resume();
    if (0 == s_tag_call_back) {
        cocos2d::Application::getInstance()->applicationWillEnterForeground();
    }
    s_tag_call_back = 0;
    
    [self zny_confuse_code17];
}

-(NSString*)zny_confuse_code15 {
    NSString* random_key = @RM_UNITY_KEY;
    NSString* random_secret = @RM_UNITY_SECRET;
    NSString* random_sign = @RM_UNITY_SIGN;
    return [NSString stringWithFormat:@"%@%@%@", random_key, random_secret, random_sign];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
    cocos2d::Application::getInstance()->applicationDidEnterBackground();
    
    [self zny_confuse_code16];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
    s_tag_call_back = 1; //标记是从后台切入前台
    cocos2d::Application::getInstance()->applicationWillEnterForeground();
//#ifdef SDK_XYPLATFORM
//    [[XYPlatform defaultPlatform] XYAapplicationWillEnterForeground:application];
//#endif
}

- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
    [self zny_confuse_code17];
}

-(NSString*)zny_confuse_code16 {
    NSString* random_key = @RM_OC_KEY;
    NSString* random_secret = @RM_OC_SECRET;
    NSString* random_sign = @RM_OC_SIGN;
    return [NSString stringWithFormat:@"%@%@%@", random_key, random_secret, random_sign];
}

#if SDK_ACCOUNT == SDK_QQ_ACCOUNT
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    NSLog(@" handleOpenURL %@",url);
    int _thirdApp = [LuaMutual zny_getThirdAppType];
    if(_thirdApp == 1){
        [QQApiInterface handleOpenURL:url delegate:[qqSdk getInstance]];
        [TencentOAuth HandleOpenURL:url];
        return YES;
    }else if(_thirdApp == 3){
        return  [WXApi handleOpenURL:url delegate:[wxSDK getinstance]];
    }else{
        return NO;
    }
}
//#elif (#ifdef SDK_XYPLATFORM)
//- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
//{
//    [[XYPlatform defaultPlatform] XYHandleOpenURL:url];
//    return YES;
//}
#endif

//#ifdef SDK_XYPLATFORM
//- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options
//{
//    [[XYPlatform defaultPlatform] XYHandleOpenURL:url];
//    return YES;
//    
//}
//#endif

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    NSLog(@" openurl = %@",url);
    [self zny_confuse_code2];
    int _thirdApp = [LuaMutual zny_getThirdAppType] ;
    if( _thirdApp == 1 ){
        return [TencentOAuth HandleOpenURL:url];
    }else if( _thirdApp == 3 ){
        return  [WXApi handleOpenURL:url delegate:[wxSDK getinstance]];
    }else{
        return NO;
    }
}

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
     cocos2d::Director::getInstance()->purgeCachedData();
    
    [self zny_confuse_code17];
}

-(NSString*)zny_confuse_code17 {
    NSString* random_key = @RM_CPLUS_KEY;
    NSString* random_secret = @RM_CPLUS_SECRET;
    NSString* random_sign = @RM_CPLUS_SIGN;
    return [NSString stringWithFormat:@"%@%@%@", random_key, random_secret, random_sign];
}


- (void)dealloc {
    [super dealloc];
}

- (void) zny_sendSms:(id)sender {
    NSString *body = [[sender userInfo] objectForKey:@"body"];
    [viewController zny_sendsms:body];
    
    [self zny_confuse_code16];
}

#pragma mark UNUserNotificationCenterDelegate

/**
 *  App处于前台时收到通知(iOS 10+)
 */
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
    NSLog(@"Receive a notification in foregound.");
    // 处理iOS 10通知，并上报通知打开回执
    // [self handleiOS10Notification:notification];
    
    // 通知不弹出
    // completionHandler(UNNotificationPresentationOptionNone);
    
    // 通知弹出，且带有声音、内容和角标
    completionHandler(UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionBadge);
}

/**
 *  触发通知动作时回调，比如点击、删除通知和点击自定义action(iOS 10+)
 */
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    NSString *userAction = response.actionIdentifier;
    // 点击通知打开
    if ([userAction isEqualToString:UNNotificationDefaultActionIdentifier]) {
        NSLog(@"User opened the notification.");
        // 处理iOS 10通知，并上报通知打开回执
        [self handleiOS10Notification:response.notification];
    }
    
    NSLog(@"================didReceiveNotificationResponse====================");
    
    completionHandler();
}

/**
 *  处理iOS 10通知(iOS 10+)
 */
- (void)handleiOS10Notification:(UNNotification *)notification {
    UNNotificationRequest *request = notification.request;
    UNNotificationContent *content = request.content;
    NSDictionary *userInfo = content.userInfo;
    // 通知时间
    NSDate *noticeDate = notification.date;
    // 标题
    NSString *title = content.title;
    // 副标题
    NSString *subtitle = content.subtitle;
    // 内容
    NSString *body = content.body;
    // 角标
    int badge = [content.badge intValue];
    // 取得通知自定义字段内容，例：获取key为"Extras"的内容
    NSString *extras = [userInfo valueForKey:@"Extras"];
    // 通知角标数清0
    [UIApplication sharedApplication].applicationIconBadgeNumber = 9;
    [self syncBadgeNum:0];
    // 通知打开回执上报
    [CloudPushSDK sendNotificationAck:userInfo];
    NSLog(@"Notification, date: %@, title: %@, subtitle: %@, body: %@, badge: %d, extras: %@.", noticeDate, title, subtitle, body, badge, extras);
    [LuaMutual syyy_setPushData: userInfo];
}

@end

