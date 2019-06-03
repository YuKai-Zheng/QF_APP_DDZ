//
//  UnityPartyBillParams.m
//  unity_pay
//
//  Created by 朱念洋 on 17/2/22.
//  Copyright © 2017年 dantezhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UnityPartyBellParams.h"

@implementation UnityPartyBellParams

-(id) init {
    if (self = [super init]) {
        self.extra = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

-(NSMutableDictionary*) zny_toDict {
    // setObject value 不能为nil，所以要加上判断
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[[NSNumber alloc] initWithInt:self.bellType] forKey:@"bill_type"];
    [dict setObject:self.userID != nil ? self.userID:@"" forKey:@"userid"];
    [dict setObject:self.itemID != nil ? self.itemID:@"" forKey:@"item_id"];
    [dict setObject:[[NSNumber alloc] initWithDouble:self.amt] forKey:@"amt"];
    [dict setObject:self.channel != nil ? self.channel:@"" forKey:@"channel"];
    [dict setObject:[[NSNumber alloc] initWithInt:self.appVersion] forKey:@"app_version"];
    [dict setObject:self.mapBellID != nil ? self.mapBellID:@"" forKey:@"map_billid"];
    [dict setObject:[[NSNumber alloc] initWithInt:self.ref] forKey:@"ref"];
    [dict setObject:self.passInfo != nil ? self.passInfo:@"" forKey:@"passinfo"];

    return dict;
}

@end
