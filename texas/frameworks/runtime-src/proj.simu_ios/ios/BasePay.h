//
//  BasePay.h
//  texas
//
//  Created by 趣凡 on 14/12/10.
//
//
#ifndef ___BASE_PAY_H___
#define ___BASE_PAY_H___
#import <Foundation/Foundation.h>
#include "SDKMacros.h"
#import "ShopInfo.h"
static NSString *APP_SOURCE = @"texas";
static NSString* APP_PLATFORM = @"ios";
static NSString * SDK_VERSION = @"2015122200";
static NSString *  APP_SECRET = @"EFyhU+#^$gCoR4knZPJ_A26tDwXO)BVd";
@protocol BasePay <NSObject>
@required
-(void) initPay ;
-(void) pay : (ShopInfo *) shopInfo cb:(paycb) cb;
-(NSString *) getPayCode : (NSString * ) itemid;
@end

#endif
