//
//  HttpBillResult.h
//  texas
//
//  Created by twl on 14-12-12.
//
//

#import <Foundation/Foundation.h>
#include <string>

@interface HttpPayCallBack : NSObject<NSURLConnectionDataDelegate>
-(void)waitResult:(int) bill_id : (int) _payType : (std::string) jsondata : (int) ret;

-(NSString * ) getSign;
-(NSString * ) getData;
-(void) setHostName : (NSString * ) host;

@property NSString * hostname;
@property int paytype;
@property int billid;
@property int result;
@property std::string jsondata;
@property(nonatomic,strong)NSMutableData *responseData;

@end
