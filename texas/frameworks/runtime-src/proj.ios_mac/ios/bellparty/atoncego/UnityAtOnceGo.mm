//
//  UnityAtOnceGo.m
//  unity_baba
//
//  Created by 朱念洋 on 17/2/24.
//  Copyright © 2017年 dantezhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIApplication.h>

#import "UnityPartyConstants.h"
#import "UnityAtOnceGo.h"
#import "PartyConstants.h"

static const double RESULT_TIMEOUT = 5 * 60;

static NSString* PARTY_PATH = @"L0JVTEwvcmVkaXJlY3Q="; // 发起支付的url path
static NSString* NOTIFY_PATH = @"L0JVTEwvcGF5L2Ni";         // 商户后台通知path
static NSString* FRONT_NOTIFY_PATH = @"L0JVTEwvc3VjY2Vzcw==";  // 商户前台通知path

static NSString* FUNCODE = @"WP001";//功能码

static NSString* MHT_ORDER_TYPE = @"01";//商户交易类型   01普通消费
static NSString* MHT_CURRENCY_TYPE = @"156";//商户订单币种   156人民币
static NSString* MHT_CHARSET = @"UTF-8";//商户字符编码
static NSString* DEVICE_TYPE = @"06";//设备类型
static NSString* MHT_SIGN_TYPE = @"MD5";//商户签名方法

@interface UnityAtOnceGo()

@property (nonatomic, copy) NSString* atOnceGoAppID;

@end

@implementation UnityAtOnceGo

+(NSString*) PARTY_CHANNEL_TYPE_BANK {
    return @"11";
}

+(NSString*) PARTY_CHANNEL_TYPE_BABA {
    return @"12";
}

+(NSString*) PARTY_CHANNEL_TYPE_WEIXIN {
    return @"13";
}

-(id)init: (NSString*)host source: (NSString*)source secret: (NSString*) secret
atOnceGoAppID: (NSString*)atOnceGoAppID
{
    if (self = [super init]) {
        _unityParty = [[UnityParty alloc] init: host source:source secret:secret];
        self.resultTimeout = RESULT_TIMEOUT;
        self.atOnceGoAppID = atOnceGoAppID;
    }
    
    return self;
}

-(void)zny_party: (UnityPartyBellParams*)bellParams onResult: (UNITY_PARTY_RESULT_CALLBACK)onResult {
    
    [self zny_allocBell:bellParams onResult:onResult];
}

-(void) zny_allocBell: (UnityPartyBellParams*)bellParams onResult: (UNITY_PARTY_RESULT_CALLBACK)onResult {
    [self.unityParty zny_allocBell:bellParams onSucc:^(int bellID) {
        [self zny_callSDK:bellID bellParams:bellParams onResult:onResult];
    } onFail:^(int result) {
        if (onResult) {
            onResult(result, 0);
        }
    }];
}

-(void) zny_callSDK: (int) bellID bellParams:(UnityPartyBellParams*)bellParams onResult: (UNITY_PARTY_RESULT_CALLBACK)onResult {
    
    NSString* itemName = [bellParams.extra objectForKey:@"item_name"];
    NSString* partyChannelType = [bellParams.extra objectForKey:@"party_channel_type"];
    
    NSMutableDictionary* dataDict = [[NSMutableDictionary alloc] init];
    
//    [dataDict setObject:self.unityParty.source forKey:@"_source"];
    
    [dataDict setObject:self.atOnceGoAppID forKey:@"appId"];
    [dataDict setObject:[NSNumber numberWithInt:bellID]  forKey:@"mhtOrderNo"];
    [dataDict setObject:itemName  forKey:@"mhtOrderName"];
    [dataDict setObject:MHT_ORDER_TYPE  forKey:@"mhtOrderType"];
    [dataDict setObject:MHT_CURRENCY_TYPE  forKey:@"mhtCurrencyType"];
    [dataDict setObject:[NSNumber numberWithInt:bellParams.amt * 100]  forKey:@"mhtOrderAmt"];
    [dataDict setObject:itemName  forKey:@"mhtOrderDetail"];
    [dataDict setObject:[self zny_getDate] forKey:@"mhtOrderStartTime"];
    
    NSString* font_url=@"ddz-https.quyifun.com";//测试服192.168.1.113:25100
    self.unityParty.host=font_url;
    [dataDict setObject:[self.unityParty zny_genHttpUrl:[UnityParty zny_base64DecodeWithString:NOTIFY_PATH]] forKey:@"notifyUrl"];
    [dataDict setObject:[self.unityParty zny_genUrl:[UnityParty zny_base64DecodeWithString:FRONT_NOTIFY_PATH]]  forKey:@"frontNotifyUrl"];
    [dataDict setObject:MHT_CHARSET  forKey:@"mhtCharset"];
    [dataDict setObject:partyChannelType  forKey:[UnityParty zny_base64DecodeWithString:@"cGF5Q2hhbm5lbFR5cGU="]];
    [dataDict setObject:FUNCODE  forKey:@"funcode"];
    [dataDict setObject:DEVICE_TYPE  forKey:@"deviceType"];
    [dataDict setObject:MHT_SIGN_TYPE  forKey:@"mhtSignType"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dataDict
                                                       options:kNilOptions error:nil];
    
    NSString* strData = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString* sign = [UnityParty zny_genMD5:[NSString stringWithFormat:@"%@|%@|%@", self.unityParty.secret, [UnityParty zny_base64DecodeWithString:PARTY_PATH], strData]];
    
    self.unityParty.host = [UnityParty zny_base64DecodeWithString:PARTY_HOST_PATH];
    NSString* url = [NSString stringWithFormat:@"%@?data=%@&sign=%@",
                     [self.unityParty zny_genUrl:[UnityParty zny_base64DecodeWithString:PARTY_PATH]], [UnityParty zny_urlEncode:strData], [UnityParty zny_urlEncode:sign]];
    
    [self zny_openUrl:url channel:partyChannelType];
    
    [self zny_getBellResult:bellID onResult:onResult];
}
-(void) zny_getBellResult: (int)bellID onResult: (UNITY_PARTY_RESULT_CALLBACK)onResult {
    [self.unityParty zny_getBellResult:bellID totalTimeout:self.resultTimeout
                          onSucc:^() {
                              if (onResult) {
                                  onResult(0, bellID);
                              }
                          }
                          onFail:^(int result) {
                              if (onResult) {
                                  onResult(result, bellID);
                              }
                          }];
}

-(void) zny_openUrl: (NSString*) url {
    
    // 这里为了简单直接使用系统浏览器打开，可以继承重写用 WebView 加载，体验更好
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url] options:@{} completionHandler:nil];
    NSLog(@"openURL: url= %@", url);

}

-(void) zny_openUrl: (NSString*) url channel:(NSString*)partyChannelType {
}

-(NSString*) zny_getDate {
    NSDateFormatter* dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    return [dateFormatter stringFromDate:[NSDate date]];
}

@end
