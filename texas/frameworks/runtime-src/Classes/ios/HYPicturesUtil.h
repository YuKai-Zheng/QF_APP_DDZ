//
//  HYPicturesUtil
//  texas
//
//  Created by zny on 14/11/22.
//  Modified by hy on 17-8-2
//
//



#import <Foundation/Foundation.h>

@interface HYPicturesUtil : NSObject


+ (NSString *)zny_postRequestWithURL: (NSString *)url
                     postParems: (NSMutableDictionary *)postParems
                     picInfo: (NSArray *) picInfo
                     luacb : (int ) luacb;
+ (NSString *)zny_requestApplyAuth: (NSString *)url
                     postParems: (NSMutableDictionary *)postParems
                     picInfo: (NSArray *) picInfo
                     luacb : (int ) luacb;

+ (NSData *)zny_getImageData : (NSString *) path;
@end
