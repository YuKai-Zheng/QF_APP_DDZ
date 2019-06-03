#import <Foundation/Foundation.h>
#import "BasePay.h"


@interface HaiMaPay : NSObject<BasePay>
@property paycb payCallBack;
@property (assign) id iap;
+(HaiMaPay*)getInstance;
@end