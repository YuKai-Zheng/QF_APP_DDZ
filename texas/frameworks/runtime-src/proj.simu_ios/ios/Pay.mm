

#import "Pay.h"
#include <vector>
#include "IOSiAP.h"
using namespace std;

@implementation Pay


////{dxType=dxType,ydType=ydType,ltType=ltType,userId = Cache.user.uin,
//item_id= shopInfo.item_id,desc=shopInfo.desc,extra= shopInfo.extra,cost = shopInfo.cost,
//extra_desc = shopInfo.extra_desc,gold = shopInfo.gold,payType = shopInfo.payType}
- (void)pay:(ShopInfo *)shopInfo cb:(paycb)cb{
    
    NSLog(@"支付id = %d",shopInfo.int_bill_id);
    
    _payCallBack = cb;
    
    [_iap setCb:[self](int code, std::string msg){
        NSLog(@" pay ret = %d %s",code,msg.c_str());
        _payCallBack(code,msg);
    }];
    
    [_iap buy:shopInfo.apple_id];
}

-(void) initPay{
    NSLog(@" init pay -----");
    _iap = [[IOSiAP alloc]init];
    [_iap RequestProductData];
}

-(NSString *) getPayCode:(NSString *)itemid{
    return itemid;
}

- (void)dealloc
{
    [shopInfo release];
    [super dealloc];
}

@end
