#import <Foundation/Foundation.h>
#import "IOSiAP.h"

#include "IOSPay.h"


@interface Pay : NSObject<BasePay>
@property paycb payCallBack;
@property (assign) id iap;
@end