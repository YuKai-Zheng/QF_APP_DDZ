//
//  wxSDK.h
//  texas
//
//  Created by qf on 15/7/9.
//
//
#ifndef texas_wxSDK_h
#define texas_wxSDK_h
#import "WXApi.h"

@interface wxSDK : NSObject<WXApiDelegate>
-(void) onResp:(BaseResp*)resp;
+(wxSDK *)getinstance;
- (void) zny_getCode;
- (NSString *) zny_getWXCanShow;
- (void) zny_shareToWX:(NSDictionary *)args;
- (UIImage *)zny_scaleImage:(UIImage *)image toScale:(float)scaleSize;
- (void) zny_openMiniProgram:(NSInteger)uin;
@end
#endif
