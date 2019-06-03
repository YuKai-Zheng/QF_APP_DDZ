//
//  IOSPay.m
//  texas
//
//  Created by jiangliwu on 14/12/9.
//
//

#import "IOSPay.h"
#include "SDKMacros.h"
#include "IOSNative.h"
#include "CCLuaBridge.h"
#include "HttpBillResult.h"
#include "HttpPayCallBack.h"

USING_NS_CC;



#define EASY_2_PAY_TYPE (32)
#define CALL_CASH_CARD12_TYPE (33)
#define MOL_POINT_CARD_TYPE (34)
#define TRUE_MONEY_TYPE (35)
#define HAPPY_CASH_CARD_TYPE (36)
#define IPAYNOW_PAY_TYPE_UNION (38)
#define IPAYNOW_PAY_TYPE_ALIPAY (39)
#define IPAYNOW_PAY_TYPE_WEIXIN (40)
#define PAY_TYPE_ALIPAY (2)
#define PAY_TYPE_HAIMA (45)

#include "Pay.h"


//@interface IOSPay ()<NSURLConnectionDataDelegate>
//    @property (weak, nonatomic) IBOutlet UITextField *username;
//    @property (weak, nonatomic) IBOutlet UITextField *pwd;
//    @property(nonatomic,strong)NSMutableData *responseData;
//@end

@implementation IOSPay

+ (void)pay:(NSDictionary *)args {
    if (shopInfo) {
        [shopInfo release];
    }
    shopInfo = [[ShopInfo alloc] init];
    shopInfo.item_id =  [args objectForKey:@"item_id"];
    shopInfo.name =  [args objectForKey:@"name"];
    shopInfo.userId =[NSString stringWithFormat:@"%d", [[args objectForKey:@"userId"] intValue]];
    shopInfo.cost = [args objectForKey:@"cost"];
    shopInfo.apple_id = [args objectForKey:@"apple_id"];
    shopInfo.gold = [args objectForKey:@"gold"];
    shopInfo.payType =[args objectForKey:@"payType"];
    shopInfo.cardNumber =[args objectForKey:@"cardNumber"];
    shopInfo.payCode = [payInstance getPayCode:shopInfo.item_id];
    shopInfo.luaCB = [[args objectForKey:@"cb"] intValue];
    shopInfo.billType = [NSNumber numberWithInt:[[args objectForKey:@"paymethod"] intValue]];
    shopInfo.cur = [args objectForKey:@"cur"];
    hostName = [[NSString alloc] initWithString:[args objectForKey:@"host"]];
    shopInfo.ref=[NSNumber  numberWithInt:[[args objectForKey:@"ref"] intValue]];
    shopInfo.int_bill_id = [self productBillId:shopInfo];
    
    
    if (shopInfo.int_bill_id > 0) {
            // IOS IAP
            [payInstance pay:shopInfo cb: [self](int code, std::string msg) {
                NSLog(@"resutMsg===%d %s %d",code,msg.c_str(),[shopInfo.payType intValue]);
                [self payCallBack:code :msg];
            } ];
    }
}

+(void) ezplayCallback {
    /**[IOSPay callBackLua:(1) :[shopInfo.payType intValue]]; // 显示转圈圈
    if (httpPaycb != nil ) {
        [httpPaycb release];
    }
    httpPaycb = [[HttpPayCallBack alloc] init];
    [httpPaycb setHostName:hostName];
    [httpPaycb waitResult:shopInfo.int_bill_id :[shopInfo.payType intValue ] :"" :0];**/
}

+ (void ) payCallBack:(int)code :(std::string)msg {
    
#if (SDK_TARGET == SDK_HAIMA )
    
    if (code == 0) {
        if (httpResult) {
            [httpResult release];
        }
        httpResult = [[HttpBillResult alloc] init];
        [httpResult waitResult: shopInfo.int_bill_id : [shopInfo.payType intValue ]];
        [IOSPay callBackLua:(1) :[shopInfo.payType intValue]];
    }else{
        [IOSPay callBackLua:(code) :[shopInfo.payType intValue]];
    }
#elif (SDK_TARGET == SDK_BLANK)

    
#elif (SDK_TARGET == SDK_APPSTORE)
    [IOSPay callBackLua:(1) :[shopInfo.payType intValue]]; // 显示转圈圈
    if (httpPaycb != nil ) {
        [httpPaycb release];
    }
    httpPaycb = [[HttpPayCallBack alloc] init];
    [httpPaycb setHostName:hostName];
    [httpPaycb waitResult:shopInfo.int_bill_id :[shopInfo.payType intValue ] :msg :code];
#endif
    
}

+ (void ) initPay  {
    httpResult = nil;
    httpPaycb = nil;
    payInstance = [[Pay alloc] init];
    [payInstance initPay];
    
    
    NSString *  identify= [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"] ;
    if( [identify isEqual:@"com.qufan.thtexas"]){
        APP_SOURCE = [[NSString alloc] initWithFormat:@"%@_%@",APP_SOURCE,@"hw"];
    }
    
}

+ (NSString *) dictToJson:(NSDictionary *) dict {
    NSError *parseError = nil;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&parseError];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

+ (int) productBillId:(ShopInfo *)shopInfo{
    NSString * channel = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"Channel"];
    NSNumber * version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];

    //cur THB USD
    NSArray * keys = [NSArray arrayWithObjects:@"userid",@"ref",@"item_id",@"bill_type",@"source",@"passinfo",
                      @"os",@"app_version",@"sdk_version", @"channel",@"extra",nil];
    NSArray * objects = [NSArray arrayWithObjects:shopInfo.userId,shopInfo.ref,shopInfo.item_id,shopInfo.billType,APP_SOURCE,@"",APP_PLATFORM,version,SDK_VERSION, channel,[NSDictionary dictionaryWithObjectsAndKeys:shopInfo.cost,@"cost",nil],nil];
    NSDictionary* jsonDict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    NSString* jsonStr = [self dictToJson:jsonDict];
    //NSLog(@"bill jsondata = %@",jsonStr);

    NSString *path= @"/bill/alloc_v2";
    NSString *sign_source = [NSString stringWithFormat:@"%@|%@|%@",APP_SECRET,path,jsonStr];
    NSString *input_sign= [IOSNative MD5:sign_source];

    NSString *url_request = [NSString stringWithFormat:@"http://%@/bill/alloc_v2",hostName];
    NSURL *url = [NSURL URLWithString:url_request];
    
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];//默认为get请求
    request.HTTPMethod = @"POST";//设置请求方法
    request.timeoutInterval = 5.0;//设置请求超时为5秒
    
    NSString *param=[NSString stringWithFormat:@"data=%@&sign=%@", [IOSPay urlencode:jsonStr], input_sign];
    request.HTTPBody=[param dataUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSDictionary *resDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    
    NSNumber *ret = [resDict objectForKey:@"ret"];
    NSLog(@"billResult==%@",ret);
    
    NSNumber* bill_id = [resDict objectForKey:@"bill_id"];
    NSString *sign = [resDict objectForKey:@"sign"];
    NSString *sign_verify = [NSString stringWithFormat:@"%@|%@|%@|%@",APP_SECRET,path,jsonStr, bill_id];
    NSString *result_verify = [IOSNative MD5:sign_verify];
    BOOL isequal = [sign isEqualToString:result_verify];
    
    if (isequal)
    {
        return [bill_id intValue];
    }else{
        [IOSPay callBackLua:(1001) :[shopInfo.payType intValue]];
        return -1;
    }
    
    //[self reloadView:resDict];
    NSLog(@"bool:%d",isequal);
}

/**
 *resutCode 0 支付成功 1001订单生成失败
 *
 */
+(void) callBackLua:(int) resutCode :(int)payType{
    if (shopInfo.luaCB>0) {
        if (resutCode == 1) {
            LuaBridge::retainLuaFunctionById(shopInfo.luaCB);
        }
        LuaBridge::pushLuaFunctionById(shopInfo.luaCB);
        
        NSArray * keys = [NSArray arrayWithObjects:@"resultCode",@"payType",nil];
        NSArray * objects = [NSArray arrayWithObjects:
                    [NSString stringWithFormat:@"%d",resutCode],
                     [NSString stringWithFormat:@"%d",payType],nil];
        NSDictionary* jsonDict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
        NSError *parseError = nil;
        //NSDictionary转换为Data
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted error:&parseError];
        //Data转换为JSON
        NSString* jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@" ---- buy ret --- = %@",jsonStr);
        LuaBridge::getStack()->pushString([jsonStr UTF8String]);
        LuaBridge::getStack()->executeFunction(1);
        LuaBridge::releaseLuaFunctionById(shopInfo.luaCB);
    }
}

+(NSString *) urlencode:(NSString *)value {
    return [value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}
@end
