//
//  NSObject+ShopInfo.h
//  texas
//
//  Created by twl on 14-12-10.
//
//

#import <Foundation/Foundation.h>

@interface ShopInfo:NSObject

    @property (nonatomic ,retain) NSString * userId ,*item_id , *name,*desc ,*extra ,*cost,*extra_desc,*gold,*payType,*payCode,*cur,*cardNumber,*pinNumber,*apple_id;
    @property (nonatomic) int int_bill_id ,luaCB;
    @property (nonatomic,retain) NSNumber* billType;
    @property (nonatomic,retain) NSNumber* ref;
@end
