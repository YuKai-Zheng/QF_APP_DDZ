//
//  HttpBillResult.h
//  texas
//
//  Created by twl on 14-12-12.
//
//

#import <Foundation/Foundation.h>

@interface HttpBillResult : NSObject<NSURLConnectionDataDelegate>
-(void)waitResult:(int) bill_id : (int) _payType;

    @property (nonatomic) int int_bill_id ;
    @property (nonatomic) int payType ;
    @property(nonatomic,strong)NSMutableData *responseData;
@end
