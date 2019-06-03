//
//  qqSdk.m
//  texas
//
//  Created by qf on 15/8/19.
//
//

#import "qqSdk.h"
#import "LuaMutual.h"

static qqSdk *s_sharedInstance = NULL;
static TencentOAuth *s_tencentOAuth = NULL;
static NSString* m_qqAppId;
static int share_scene = 0;
static int share_type = 0;

@implementation qqSdk

+ (qqSdk *)getInstance {
    if (NULL == s_sharedInstance) {
        m_qqAppId = [LuaMutual zny_getQqAppId];
        s_sharedInstance = [[qqSdk alloc] init];
        s_tencentOAuth = [[TencentOAuth alloc] initWithAppId:m_qqAppId andDelegate:s_sharedInstance];
    }
    return s_sharedInstance;
}
// login QQ
- (void)zny_loginQQ {
    [s_tencentOAuth authorize:[NSArray arrayWithObjects:
                               kOPEN_PERMISSION_GET_USER_INFO,
                               kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
                               kOPEN_PERMISSION_ADD_SHARE,
                               nil] inSafari:NO];
}

// 分享内容到QQ
- (void)zny_shareNewsToQQ:(NSDictionary *)args {
    // 跳转URL
    NSString *targetUrl = [args objectForKey:@"targetUrl"];
    // 分享图预览图URL地址
    NSString *localPath = [args objectForKey:@"localPath"];
    NSData *data = [NSData dataWithContentsOfFile:localPath];
    // title
    NSString *title = [args objectForKey:@"title"];
    // description
    NSString *description = [args objectForKey:@"description"];
    QQApiNewsObject *newsObj = [QQApiNewsObject objectWithURL:[NSURL URLWithString:targetUrl] title:title description:description previewImageData:data];
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
    
    int scene = [[args objectForKey:@"scene"] intValue];
    int type  = [[args objectForKey:@"type"] intValue];
    share_scene = scene;
    share_type = type;
    
    QQApiSendResultCode sent;
    if (scene == 1) { // QQ
        sent = [QQApiInterface sendReq:req];
    } else if (scene == 2) { // QQ zone
        sent = [QQApiInterface SendReqToQZone:req];
    }
    [self handleSendResult:sent];
}
// 分享图片到QQ
- (void)zny_shareImageToQQ:(NSDictionary *)args {
    NSString *localPath = [args objectForKey:@"localPath"];
    NSData *data = [NSData dataWithContentsOfFile:localPath];
    QQApiImageObject* imgObj = [QQApiImageObject objectWithData:data previewImageData:data title:[args objectForKey:@"title"] description:[args objectForKey:@"description"]];
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:imgObj];
    
    int scene = [[args objectForKey:@"scene"] intValue];
    int type  = [[args objectForKey:@"type"] intValue];
    share_scene = scene;
    share_type = type;
    
    QQApiSendResultCode sent;
    if (scene == 1) { // QQ
        sent = [QQApiInterface sendReq:req];
    } else if (scene == 2) { // QQ zone
        sent = [QQApiInterface SendReqToQZone:req];
    }
    [self handleSendResult:sent];
}
- (void)handleSendResult:(QQApiSendResultCode)sendResult {
    switch (sendResult)
    {
        case EQQAPISENDSUCESS: {
            NSMutableDictionary *multDict = [[NSMutableDictionary alloc] init];
            [multDict setObject:@"success" forKey:@"result"];
            [multDict setObject:[NSNumber numberWithInt:share_scene] forKey:@"scene"];
            [multDict setObject:[NSNumber numberWithInt:share_type] forKey:@"type"];
            [LuaMutual zny_sdkShareResultCallback:multDict];
            break;
        }
        case EQQAPIAPPNOTREGISTED:
        case EQQAPIMESSAGECONTENTINVALID:
        case EQQAPIMESSAGECONTENTNULL:
        case EQQAPIMESSAGETYPEINVALID:
        case EQQAPIQQNOTINSTALLED:
        case EQQAPIQQNOTSUPPORTAPI:
        case EQQAPISENDFAILD:
        default: {
            NSMutableDictionary *multDict = [[NSMutableDictionary alloc] init];
            [multDict setObject:[NSNumber numberWithInt:share_scene] forKey:@"scene"];
            [multDict setObject:[NSNumber numberWithInt:share_type] forKey:@"type"];
            [multDict setObject:@"fail" forKey:@"result"];
            [LuaMutual zny_sdkShareResultCallback:multDict];
            break;
        }
    }
}

- (NSDictionary *) zny_getOpenIDAndToken {
    NSMutableDictionary * ret = [[NSMutableDictionary alloc] init];
    [ret setObject:s_tencentOAuth.openId forKey:@"openid"];
    [ret setObject:s_tencentOAuth.accessToken forKey:@"token"];
    [ret setObject:[NSString stringWithFormat:@"%ld",(long)[s_tencentOAuth.expirationDate timeIntervalSince1970]] forKey:@"date"];
    return ret;
}

- (NSString *)zny_getQQCanShow{
    NSString * ret;
    if ([TencentOAuth iphoneQQInstalled] == YES){
        ret = @"1";
    }else{
        ret = @"0";
    }
    
    return ret;
}

- (void)tencentDidLogin {
    if (s_tencentOAuth.accessToken && 0 != [s_tencentOAuth.accessToken length]) {
        [LuaMutual zny_qqLoginSuccess];
        //[[NSNotificationCenter defaultCenter] postNotificationName:kLoginSuccessed object:self];
    } else {
        [LuaMutual zny_qqLoginFailed];
        //[[NSNotificationCenter defaultCenter] postNotificationName:kLoginFailed object:self];
    }
}

- (void)tencentDidNotLogin:(BOOL)cancelled
{
    [LuaMutual zny_qqLoginFailed];
    //[[NSNotificationCenter defaultCenter] postNotificationName:kLoginFailed object:self];
}

- (void)tencentDidNotNetWork
{
    [LuaMutual zny_qqLoginFailed];
    //[[NSNotificationCenter defaultCenter] postNotificationName:kLoginFailed object:self];
}

- (NSArray *)getAuthorizedPermissions:(NSArray *)permissions withExtraParams:(NSDictionary *)extraParams
{
    return nil;
}

- (void)tencentDidLogout
{
    
}

- (void)onReq:(QQBaseReq *)req {
    
}

- (void)onResp:(QQBaseResp *)resp {
    
}

@end
