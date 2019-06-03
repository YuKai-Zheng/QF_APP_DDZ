//
//  ImagePostHelper
//  texas
//
//  Created by Jiangliwu on 14/11/22.
//
//



#import <Foundation/Foundation.h>

@interface ImagePostHelper : NSObject


+ (NSString *)postRequestWithURL: (NSString *)url
                     postParems: (NSMutableDictionary *)postParems
                     picInfo: (NSArray *) picInfo
                     luacb : (int ) luacb;
+ (NSString *)requestApplyAuth: (NSString *)url
                     postParems: (NSMutableDictionary *)postParems
                     picInfo: (NSArray *) picInfo
                     luacb : (int ) luacb;

+ (NSData *) getImageData : (NSString *) path;
@end