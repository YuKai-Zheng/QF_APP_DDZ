
#import "IOSMacro.h"
#import "HaiMaPay.h"
#include <vector>
#include "IOSiAP.h"
#import "IOSNative.h"
using namespace std;

#if (SDK_TARGET == SDK_HAIMA )
#import <ZHPay/ZHPayPlatform.h>

@interface HaiMaPay() <ZHPayDelegate,ZHPayResultDelegate,ZHPayCheckDelegate,UIAlertViewDelegate>
{
    NSString *lastOrderId;
}
@end
#endif


static HaiMaPay * s_HaiMaPay = nil;

@implementation HaiMaPay

+(HaiMaPay*)getInstance{
    if (s_HaiMaPay == NULL) {
        s_HaiMaPay = [[HaiMaPay alloc]init];
    }
    return s_HaiMaPay;
}

-(void) initPay{
    NSLog(@" init pay -----");
    #if (SDK_TARGET == SDK_HAIMA )
    //填写您的AppID
    [ZHPayPlatform initWithAppId:@"45e6e5210da265f035b232a5fed0ec09" withDelegate:self testUpdateMode:NO alertTypeCheckFailed:2];
    [ZHPayPlatform setSupportOrientation:UIInterfaceOrientationMaskAll];
    [ZHPayPlatform setLogEnable:NO];
    #endif
}

#if (SDK_TARGET == SDK_HAIMA )

- (void)pay:(ShopInfo *)shopInfo cb:(paycb)cb{
    
    NSLog(@" hai ma orderId:%d",shopInfo.int_bill_id);
    NSString *orderId = [NSString stringWithFormat:@"%d",shopInfo.int_bill_id];
    lastOrderId = orderId;
    
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:@"yyyyMMddHHmmss.SSS"];
    NSString *dateString = [dateFormater stringFromDate:[NSDate date]];
    NSLog(@"time：%@",dateString);
    //orderId = dateString;
    
    //向SDK发起支付
    ZHPayOrderInfo *orderInfo = [[ZHPayOrderInfo alloc] init];
    orderInfo.orderId = orderId;
    orderInfo.productName = shopInfo.name;        //名称不可为空
    orderInfo.gameName = @"德州扑克之夜";            //不可为空
    orderInfo.productPrice = [shopInfo.cost intValue];            //人民币：元
    orderInfo.userParams = @"用户自定义参数，服务器异步通知时会原样回传";
    [ZHPayPlatform startPay:orderInfo delegate:self];
}
/**
 *	@brief	支付成功
 */
- (void)ZHPayResultSuccessWithOrder:(ZHPayOrderInfo *)orderInfo {
    NSLog(@"Demo:订单支付成功");
    //去查询自己服务器上的宝石余额
}

/**
 *	@brief	支付失败
 */
- (void)ZHPayResultFailedWithOrder:(ZHPayOrderInfo *)orderInfo resultCode:(ZH_PAY_ERROR)errorType {
    NSLog(@"Demo:订单支付失败");
}

/**
 *	@brief  用户中途取消支付
 */
- (void)ZHPayResultCancelWithOrder:(ZHPayOrderInfo *)orderInfo {
    NSLog(@"Demo:订单取消");
}


//开始登录
- (void)startZHPayLogin {
    [ZHPayPlatform startLogin];
}

- (void)ZHPayLoginSuccess:(ZHPayUserInfo *)userInfo 
{
    //NSLog(@"Demo:账号登陆成功");
    //NSLog(@"Demo:当前账号ID：%@ token:%@",userInfo.userId,userInfo.validateToken);

    [IOSNative haimaLoginCallback:userInfo.userId Token:userInfo.validateToken];
}

#endif



-(NSString *) getPayCode:(NSString *)itemid{
    return itemid;
}

- (void)dealloc
{
    [super dealloc];
}

@end
