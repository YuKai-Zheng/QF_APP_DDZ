
/*
 注意:
 
 BillParams.extra 额外增加字段:
 item_name: 商品名称
 pay_channel_type: 分别使用 PARTY_CHANNEL_TYPE_BANK/PARTY_CHANNEL_TYPE_BABA/PARTY_CHANNEL_TYPE_WEIXIN
 
 */


#import <Foundation/Foundation.h>
#import "UnityParty.h"
#import "UnitySDKParty.h"


@interface UnityAtOnceGo : NSObject <UnitySDKParty>

@property (nonatomic, strong, readonly) UnityParty* unityParty;
@property (nonatomic, assign) double resultTimeout;


+(NSString*) PARTY_CHANNEL_TYPE_BANK;
+(NSString*) PARTY_CHANNEL_TYPE_BABA;
+(NSString*) PARTY_CHANNEL_TYPE_WEIXIN;

-(id)init: (NSString*)host source: (NSString*)source secret: (NSString*) secret
atOnceGoAppID: (NSString*)atOnceGoAppID;

// onResult: result, bill_id
-(void)zny_party: (UnityPartyBellParams*)bellParams onResult: (UNITY_PARTY_RESULT_CALLBACK)onResult;

@end
