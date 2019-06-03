//
//  IOSPay.h
//  texas
//
//  Created by Jiangliwu on 14/12/9.
//
//

#include "BasePay.h"

#include "ShopInfo.h"
@class HttpBillResult;
@class HttpPayCallBack;

static id payInstance;
static ShopInfo * shopInfo;
static HttpBillResult * httpResult ;
static HttpPayCallBack * httpPaycb;
static NSString * hostName;

@interface IOSPay : NSObject{
    
}


+(void) pay : (NSDictionary * ) args;
+(void) initPay ;
+(int) productBillId : (ShopInfo*) shopInfo;
+(void) callBackLua:(int) resutCode :(int)payType;
+(void) payCallBack :(int ) code : ( std::string  ) msg;
+(void) ezplayCallback;
+(NSString * ) urlencode : (NSString * ) value;
+(NSString * ) dictToJson : (NSDictionary * ) dict;
@end
