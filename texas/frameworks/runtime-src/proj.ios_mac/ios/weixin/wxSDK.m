//
//  wxSDK.m
//  texas
//
//  Created by qf on 15/7/9.
//
//

#import <Foundation/Foundation.h>
#import "wxSDK.h"
#import "WXApi.h"
#import "WXApiObject.h"
#import "LuaMutual.h"

@implementation wxSDK
static wxSDK *g_instance = nil;
static NSString* kWXOpenID;
static int share_scene = 0;
static int share_type = 0;

+ (wxSDK *)getinstance
{
    @synchronized(self)
    {
        if (nil == g_instance)
        {
            g_instance = [[wxSDK alloc] init];
            kWXOpenID = [LuaMutual syyy_getWxAppId];
        }
    }
    return g_instance;
}

-(NSString *) zny_getWXCanShow
{
    NSString * ret;
    if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]){
        ret = @"1";
    }else{
        ret = @"0";
    }
    return ret;
}

-(void) onResp:(BaseResp*)resp
{
    if([resp isKindOfClass:[SendAuthResp class]])
    {
        SendAuthResp *temp = (SendAuthResp*)resp;
        NSMutableDictionary * ret = [[NSMutableDictionary alloc] init];
        NSString * code  = temp.code;
        if (code) {
            [ret setObject:code forKey:@"code"];
            [ret setObject:@3 forKey:@"type"];
            [LuaMutual zny_wxGetCodeSuccess:ret];
        }
    }
    if([resp isKindOfClass:[SendMessageToWXResp class]])
    {
        NSMutableDictionary *multDict = [[NSMutableDictionary alloc] init];
        int errCode = resp.errCode;
        NSString *resultMsg = nil;
        if (errCode == 0) {
            resultMsg = @"success";
        } else if (errCode == -2){
            resultMsg = @"cancel";
        } else {
            resultMsg = @"error";
        }
        NSLog(@"分享成功scene=%d type = %d",share_scene, share_type);
        [multDict setObject:resultMsg forKey:@"result"];
        [multDict setObject:[NSNumber numberWithInt:share_scene] forKey:@"scene"];
        [multDict setObject:[NSNumber numberWithInt:share_type] forKey:@"type"];
        [LuaMutual zny_sdkShareResultCallback:multDict];
    }
}
- (void) zny_getCode{
    [WXApi registerApp:[LuaMutual syyy_getWxAppId] enableMTA:false];
    
    SendAuthReq* req = [[[SendAuthReq alloc] init] autorelease];
    req.scope = @"snsapi_message,snsapi_userinfo,snsapi_friend,snsapi_contact"; // @"post_timeline,sns"
    req.state = @"xxx";
    req.openID = kWXOpenID;
    [WXApi sendAuthReq:req viewController:[LuaMutual getRootController] delegate:self];
}

- (UIImage *)zny_scaleImage:(UIImage *)image toScale:(float)scaleSize
{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
                                [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
                                UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
                                UIGraphicsEndImageContext();
                                
                                return scaledImage;
                                
                                }

// 分享到微信
- (void) zny_shareToWX : (NSDictionary *)args {
    [WXApi registerApp:[LuaMutual zny_getWxShareAppId] enableMTA:false];
    
    int share = [[args objectForKey:@"share"] intValue];
    int scene = [[args objectForKey:@"scene"] intValue];
    int type  = [[args objectForKey:@"type"] intValue];
    share_scene = scene;
    share_type = type;
    
    // 跳转URL
    NSString *targetUrl = [args objectForKey:@"targetUrl"];
    // 分享图预览图URL地址
    NSString *previewImageUrl = [args objectForKey:@"localPath"];
    // title
    NSString *title = [args objectForKey:@"title"];
    // description
    NSString *description = [args objectForKey:@"description"];
    
    WXMediaMessage *message = [WXMediaMessage message];

    int ratioGame = [[args objectForKey:@"ratioGame"] intValue];
    if (ratioGame == 0){
        [message setThumbImage:[self zny_scaleImage: [UIImage imageNamed:previewImageUrl] toScale:0.3]];
    }else{
        [message setThumbImage:[self zny_scaleImage: [UIImage imageNamed:previewImageUrl] toScale:0.1]];
    }
    
    WXImageObject *extImage = nil;
    WXWebpageObject *extWebpage = nil;
    
    if (share == 1) {//分享图片
        extImage = [WXImageObject object];
        extImage.imageData = [NSData dataWithContentsOfFile:previewImageUrl];
        
        message.mediaTagName = @"德州扑克之夜TAG";
        message.messageExt = @"这个是测试字段，看一下到底是在哪里出现";
        message.messageAction = @"这个字段不知道是什么用！";
        message.mediaObject = extImage;
        message.description = description;
    } else if (share == 2) {//分享图文链接
        extWebpage = [WXWebpageObject object];
        extWebpage.webpageUrl = targetUrl;
        
        if (scene == 2) {
            message.title = description;
        } else {
            message.title = title;
        }
        message.description = description;

        message.mediaObject = extWebpage;
    }
    
    SendMessageToWXReq* req = [[[SendMessageToWXReq alloc] init]autorelease];
    req.bText = NO;
    req.message = message;
    
    if (scene == 1) { // 会话
        req.scene = WXSceneSession;
    } else if (scene == 2) { // 朋友圈
        req.scene = WXSceneTimeline;
    }
    [WXApi sendReq:req];
}

- (void) zny_openMiniProgram:(NSInteger)uin{
    [WXApi registerApp:[LuaMutual zny_getWxShareAppId] enableMTA:false];

    WXLaunchMiniProgramReq *launchMiniProgramReq = [WXLaunchMiniProgramReq object];
    launchMiniProgramReq.userName = @"gh_9a3e0d76b08a";  //拉起的小程序的username
    NSString *str = @"pages/xxx/xxx?from=CN_IOS_APPDDZ&uin=";
    launchMiniProgramReq.path = [NSString stringWithFormat:@"%@%zi",str,uin];   //拉起小程序页面的可带参路径，不填默认拉起小程序首页
    launchMiniProgramReq.miniProgramType = 0; // 正式版:0，测试版:1，体验版:2
    [WXApi sendReq:launchMiniProgramReq];
}

@end
