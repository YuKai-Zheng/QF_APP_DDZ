#import <Foundation/Foundation.h>
#import "UnityPartyBellParams.h"


// 结果通知
// result: 0: 成功；其他: 失败
// bellID: >0 订单ID; 其他: 尚未生成
typedef void (^UNITY_PARTY_RESULT_CALLBACK)(int, int);


@interface UnityParty: NSObject

@property (nonatomic, copy) NSString * host;
@property (nonatomic, copy) NSString * source;
@property (nonatomic, copy) NSString * secret;

@property (nonatomic, copy) NSString * scheme;

// 超时时间（秒）。<=0: 不设置超时
@property (nonatomic, assign) double timeout;

@property (nonatomic, assign) int taskQueueMaxSize;


-(id) init: (NSString*) host source: (NSString*)source secret: (NSString*) secret;

-(void) zny_allocBell: (UnityPartyBellParams*)bellParams
onSucc: (void (^)(int))onSucc
onFail:(void (^)(int))onFail;

-(void) zny_getBellResult: (int)bellID
totalTimeout: (double)totalTimeout
onSucc: (void (^)())onSucc
onFail:(void (^)(int))onFail;

-(void) zny_setBellResult: (int)bellID result: (int)result data: (NSDictionary*)data
onSucc: (void (^)())onSucc
onFail:(void (^)(int))onFail;

-(NSString*)zny_genUrl: (NSString*)path;
-(NSString*)zny_genHttpUrl: (NSString*)path;

+(NSString*) zny_urlEncode: (NSString*)src;
+(NSString*) zny_urlDecode: (NSString*)src;
+(NSString*) zny_genMD5:(NSString*)src;

+(NSString*)zny_base64DecodeWithString: (NSString*)path;

@end
