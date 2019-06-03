//
//  IOSPay.m
//  texas
//
//  Created by jiangliwu on 14/12/9.
//
//

#import "PartyConstants.h"
#import "UnitySDKPartyFactory.h"
#import "UnityPartyBellParams.h"

#include "CCLuaBridge.h"

USING_NS_CC;

#import "UnityAtOnceGoWeb.h"
#import "UnityAppleParty.h"

static UnityAtOnceGoWeb* unityAtOnceGo;
static UnityAppleParty* unityAppleParty;

@implementation UnitySDKPartyFactory

static UnitySDKPartyFactory* factoryInstance = nil;

+ (id)getInstance {
    if (factoryInstance == nil) {
        factoryInstance = [[UnitySDKPartyFactory alloc] init];
    }
    return factoryInstance;
}
- (void)zny_initParty {
    unityAtOnceGo = [[UnityAtOnceGoWeb alloc] init: [UnityParty zny_base64DecodeWithString:PARTY_HOST_PATH]
                                        source: PARTY_SOURCE
                                        secret: PARTY_SECRET
                                    atOnceGoAppID: ATONCEGO_APPID
                      ];
    unityAppleParty = [[UnityAppleParty alloc] init: [UnityParty zny_base64DecodeWithString:PARTY_HOST_PATH]
                                                source: PARTY_SOURCE
                                                secret: PARTY_SECRET
                            ];

    [self zny_confuse_code11];
}

-(NSString*)zny_confuse_code11 {
    NSString* random_key = @RM_C_KEY;
    NSString* random_secret = @RM_C_SECRET;
    NSString* random_sign = @RM_C_SIGN;
    return [NSString stringWithFormat:@"%@%@%@", random_key, random_secret, random_sign];
}

- (void)zny_startParty:(NSDictionary *)args {
    UnityPartyBellParams* bellParams = [[UnityPartyBellParams alloc] init];
    
    bellParams.ref = [[args objectForKey:@"ref"] intValue];
    bellParams.amt = [[args objectForKey:@"cost"] doubleValue];
    bellParams.itemID = [args objectForKey:@"item_id"];
    bellParams.userID = [args objectForKey:@"user_id"];
    bellParams.bellType = [[args objectForKey:@"bill_type"] intValue];
    bellParams.channel = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"Channel"];
    bellParams.appVersion = [[args objectForKey:@"version"] intValue];

    [bellParams.extra setObject:[args objectForKey:@"cb"] forKey:@"cb"];
    [bellParams.extra setObject:[args objectForKey:@"host"] forKey:@"host"];
    [bellParams.extra setObject:[args objectForKey:@"source"] forKey:@"source"];
    [bellParams.extra setObject:[args objectForKey:@"item_name"] forKey:@"item_name"];
    [bellParams.extra setObject:[args objectForKey:@"proxy_item_id"] forKey:@"proxy_item_id"];

    NSLog(@"bellParams.extra%@",bellParams.extra);
    if(bellParams.bellType == BELL_TYPE_ATONCEGO_UNION
        || bellParams.bellType == BELL_TYPE_ATONCEGO_WEIXIN
        || bellParams.bellType == BELL_TYPE_ATONCEGO_BABA)
    {
        [self zny_startAtOnceGo:bellParams];
    }
    else
    {
        // IOS IAP
        [self zny_startAppleParty:bellParams];
    }
    NSLog(@"bellParams.extra%@",bellParams.extra);
    [self zny_confuse_code12];
}

-(NSString*)zny_confuse_code12 {


    NSString* random_key = @RM_OC_KEY;
    NSString* random_secret = @RM_OC_SECRET;
    NSString* random_sign = @RM_OC_SIGN;
    return [NSString stringWithFormat:@"%@%@%@", random_key, random_secret, random_sign];
}

// 现在支付
- (void)zny_startAtOnceGo:(UnityPartyBellParams*)bellParams {
    if(bellParams.bellType == BELL_TYPE_ATONCEGO_UNION) {
        [bellParams.extra setObject:ATONCEGO_CHANNEL_UNION forKey:@"party_channel_type"];
    }
    else if(bellParams.bellType == BELL_TYPE_ATONCEGO_WEIXIN) {
        [bellParams.extra setObject:ATONCEGO_CHANNEL_WEIXIN forKey:@"party_channel_type"];
    }
    else if(bellParams.bellType == BELL_TYPE_ATONCEGO_BABA) {
        [bellParams.extra setObject:ATONCEGO_CHANNEL_BABA forKey:@"party_channel_type"];
    }
    
    [[unityAtOnceGo unityParty] setScheme:@"https"];
    [[unityAtOnceGo unityParty] setHost:[bellParams.extra objectForKey:@"host"]];
    [[unityAtOnceGo unityParty] setSource:[bellParams.extra objectForKey:@"source"]];
    [unityAtOnceGo zny_party:bellParams onResult:^(int result, int bellID) {
        NSLog(@"result: %d", result);
        [self zny_onResultCallbackLua:result cb:[[bellParams.extra objectForKey:@"cb"] intValue]];
    }];

    [self zny_confuse_code12];
}
// 苹果支付

- (void)zny_startAppleParty:(UnityPartyBellParams*)bellParams {
    [bellParams.extra setObject:bellParams.itemID forKey:@"item_code"];
    bellParams.itemID = [bellParams.extra objectForKey:@"proxy_item_id"];
    
    [[unityAppleParty unityParty] setScheme:@"https"];
    [[unityAppleParty unityParty] setHost:[bellParams.extra objectForKey:@"host"]];
    [[unityAppleParty unityParty] setSource:[bellParams.extra objectForKey:@"source"]];
    [unityAppleParty zny_party:bellParams onResult:^(int result, int bellID) {
        NSLog(@"result: %d", result);
        [self zny_onResultCallbackLua:result cb:[[bellParams.extra objectForKey:@"cb"] intValue]];
    }];
    
    [self zny_confuse_code12];
}
// 回调lua
- (void)zny_onResultCallbackLua:(int) resultCode cb:(int)cb {
    LuaBridge::pushLuaFunctionById(cb);
    
    NSArray * keys = [NSArray arrayWithObjects:@"resultCode",nil];
    NSArray * objects = [NSArray arrayWithObjects:
                [NSString stringWithFormat:@"%d",resultCode], nil];
    NSDictionary* jsonDict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    NSError *parseError = nil;
    //NSDictionary转换为Data
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted error:&parseError];
    //Data转换为JSON
    NSString* jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@" ---- buy ret --- = %@",jsonStr);
    LuaBridge::getStack()->pushString([jsonStr UTF8String]);
    LuaBridge::getStack()->executeFunction(1);
    
    [self zny_confuse_code11];
}

@end
