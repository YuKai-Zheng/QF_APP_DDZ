//
//  qqSdk.h
//  texas
//
//  Created by qf on 15/8/19.
//
//

#import <Foundation/Foundation.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/TencentOAuthObject.h>
#import <TencentOpenAPI/QQApiInterfaceObject.h>
#import <TencentOpenAPI/QQApiInterface.h>

#import "qqDef.h"

@interface qqSdk : NSObject<TencentSessionDelegate, QQApiInterfaceDelegate>

+ (qqSdk *)getInstance;

- (NSString *) zny_getQQCanShow;

- (void)zny_loginQQ;

- (void)zny_shareNewsToQQ : (NSDictionary *)args;
- (void)zny_shareImageToQQ : (NSDictionary *)args;

- (NSDictionary *) zny_getOpenIDAndToken;

- (void)handleSendResult:(QQApiSendResultCode)sendResult;

@end
