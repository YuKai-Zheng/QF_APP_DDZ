#import "UnityParty.h"
#import "UnityPartyConstants.h"

extern unsigned char *CC_MD5(const void *data, uint32_t len, unsigned char *md)
__OSX_AVAILABLE_STARTING(__MAC_10_4, __IPHONE_2_0);

@interface UnityParty()

// 线程安全
@property (atomic, strong) NSMutableArray* taskQueue;

@end

@implementation UnityParty

-(id) init: (NSString*) host source: (NSString*)source secret: (NSString*) secret
{
    if (self = [super init]) {
        self.taskQueue = [[NSMutableArray alloc] init];
        self.scheme = SCHEME_HTTP;
        self.timeout = HTTP_TIMEOUT;
        self.taskQueueMaxSize = TASK_QUEUE_MAX_SIZE;
        self.host = host;
        self.source = source;
        self.secret = secret;
    }
    
    return self;
}

+(NSString*) zny_urlEncode: (NSString*)src {
    return [src stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}

+(NSString*) zny_urlDecode: (NSString*)src {
    return [src stringByRemovingPercentEncoding];
}

+(NSString*) zny_genMD5:(NSString*)src {
    const char* str = [src UTF8String];
    unsigned char result[16];
    CC_MD5(str, (uint32_t)strlen(str), result);
    NSMutableString *ret = [NSMutableString stringWithCapacity:16 * 2];
    for(int i = 0; i<16; i++) {
        [ret appendFormat:@"%02x",(unsigned int)(result[i])];
    }
    return ret;
}

-(void) zny_allocBell: (UnityPartyBellParams*)bellParams
           onSucc: (void (^)(int))onSucc
           onFail:(void (^)(int))onFail {
    
    NSString* urlPath = [UnityParty zny_base64DecodeWithString:URL_PATH_ALLOC_BELL];
    NSLog(@"zny_allocBell：%@",urlPath);
    NSString* strUrl = [self zny_genUrl:urlPath];
    
    NSURL* url = [[NSURL alloc] initWithString:strUrl];
    
    NSMutableDictionary* jsonParams = [bellParams zny_toDict];
    [jsonParams setValue:self.source forKey:@"source"];
    [jsonParams setValue:OS forKey:@"os"];
    [jsonParams setValue:[[NSNumber alloc] initWithInt:VERSION] forKey:@"sdk_version"];
    
    if(![NSJSONSerialization isValidJSONObject:jsonParams]) {
        onFail(RESULT_HTTP_PARAMS_INVALID);
        return;
    }

    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonParams
                                                      options:kNilOptions error:nil];
    
    NSString* strData = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString* sign = [UnityParty zny_genMD5:[NSString stringWithFormat:@"%@|%@|%@", self.secret, urlPath, strData]];
    
    
    NSString* httpBody = [NSString stringWithFormat:@"data=%@&sign=%@",
                          [UnityParty zny_urlEncode:strData],
                          [UnityParty zny_urlEncode:sign]
                          ];
 
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    if (self.timeout >0) {
        [request setTimeoutInterval:self.timeout];
    }
    
    [request setHTTPMethod:@"POST"];
    
    [request setHTTPBody:[httpBody dataUsingEncoding:NSUTF8StringEncoding]];
    
    /*
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError * error) {
        //这段块代码只有在网络请求结束以后的后续处理。
        if (data != nil) {  //接受到数据，表示工作正常
        }else if(data == nil && error != nil)    //没有接受到数据，但是error为nil。。表示接受到空数据。
        {
        }else{
        }
    }];
*/
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                completionHandler:^(NSData *data, NSURLResponse* response, NSError* error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (data != nil) {
                            //接受到数据，表示工作正常
                            NSDictionary *rspDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                            
                            NSNumber* rspResult = [rspDict objectForKey:@"ret"];
                            if (rspResult == nil) {
                                onFail(RESULT_EXCEPTION);
                                return;
                            }
                            
                            if ([rspResult intValue] != 0) {
                                onFail([rspResult intValue]);
                                return;
                            }

                            NSNumber *bellID = [rspDict objectForKey:@"bill_id"];
                            
                            NSString *sign = [rspDict objectForKey:@"sign"];
                            NSString *calcSign = [UnityParty zny_genMD5:[NSString stringWithFormat:@"%@|%@|%@|%@",
                                                     self.secret, urlPath, strData, bellID]];
                            
                            if ([calcSign isEqualToString:sign]) {
                                onSucc([bellID intValue]);
                            }
                            else {
                                onFail(RESULT_SIGN_INVALID);
                            }

                        }
                        else{
                            if (error != nil) {
                                NSLog(@"http fail, url: %@, error: %@", strUrl, [error localizedDescription]);
                            }
                            else {
                                NSLog(@"http fail, url: %@", strUrl);
                            }
                            onFail(RESULT_HTTP_FAIL);
                        }
                    });
                }
    ];
    
    [task resume];
    
    [self zny_addTask:task];
}


-(void) zny_getBellResult: (int)bellID
         totalTimeout: (double)totalTimeout
               onSucc: (void (^)())onSucc
               onFail:(void (^)(int))onFail {
    
    time_t nowTime = time(NULL);
    
    NSString* urlPath = [UnityParty zny_base64DecodeWithString:URL_PATH_BELL_RESULT];
    NSString* strUrl = [self zny_genUrl:urlPath];
    
    NSURL* url = [[NSURL alloc] initWithString:strUrl];
    
    NSString* httpBody = [NSString stringWithFormat:@"bill_id=%d", bellID];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    if (totalTimeout > 0) {
        [request setTimeoutInterval:totalTimeout];
    }
    
    [request setHTTPMethod:@"POST"];
    
    [request setHTTPBody:[httpBody dataUsingEncoding:NSUTF8StringEncoding]];
    

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData *data, NSURLResponse* response, NSError* error) {
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    if (data != nil) {
                                                        //接受到数据，表示工作正常
                                                        NSDictionary *rspDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                                                        
                                                        NSNumber* rspResult = [rspDict objectForKey:@"ret"];
                                                        if (rspResult == nil) {
                                                            onFail(RESULT_EXCEPTION);
                                                            return;
                                                        }
                                                        
                                                        if ([rspResult intValue] != 0) {
                                                            onFail([rspResult intValue]);
                                                            return;
                                                        }
                                                        
                                                        NSString *sign = [rspDict objectForKey:@"sign"];
                                                        NSString *calcSign = [UnityParty zny_genMD5:[NSString stringWithFormat:@"%@|%@|%d",
                                                                                        self.secret, urlPath, bellID]];
                                                        
                                                        if ([calcSign isEqualToString:sign]) {
                                                            onSucc();
                                                        }
                                                        else {
                                                            onFail(RESULT_SIGN_INVALID);
                                                        }
                                                        
                                                    }
                                                    else{
                                                        if (error != nil) {
                                                            NSLog(@"http fail, url: %@, error: %@", strUrl, [error localizedDescription]);
                                                        }
                                                        else {
                                                            NSLog(@"http fail, url: %@", strUrl);
                                                        }
                                                        
                                                        double remainTimeout = totalTimeout - (time(NULL) - nowTime);
                                                        
                                                        if (error.code == NSURLErrorCancelled) {
                                                            // NSURLErrorCancelled(-999) 代表cancel
                                                            onFail(RESULT_HTTP_FAIL);
                                                        }
                                                        else {
                                                            if ((int)remainTimeout > 0) {
                                                                // 还有时间
                                                                [self zny_getBellResult:bellID totalTimeout:remainTimeout onSucc:onSucc onFail:onFail];
                                                            }
                                                            else {
                                                                onFail(RESULT_HTTP_FAIL);
                                                            }
                                                        }
                                                    }
                                                });
                                                
                                            }
    ];
    
    [task resume];
    
    [self zny_addTask:task];
}


-(void) zny_setBellResult: (int)bellID result: (int)result data: (NSDictionary*)data
               onSucc: (void (^)())onSucc
               onFail:(void (^)(int))onFail {
    
    NSString* urlPath = [UnityParty zny_base64DecodeWithString:URL_PATH_APP_PARTY_CB];
    NSString* strUrl = [self zny_genUrl:urlPath];
    
    NSURL* url = [[NSURL alloc] initWithString:strUrl];
    
    NSString* strData = @"";
    if (data != nil) {
        if(![NSJSONSerialization isValidJSONObject:data]) {
            onFail(RESULT_HTTP_PARAMS_INVALID);
            return;
        }

        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data
                                                           options:kNilOptions error:nil];

        strData = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }

    NSString* sign = [UnityParty zny_genMD5:[NSString stringWithFormat:@"%@|%@|%d|%d|%@",
                                self.secret, urlPath, bellID, result, strData]];
    
    
    NSString* httpBody = [NSString stringWithFormat:@"bill_id=%d&result=%d&data=%@&sign=%@",
                          bellID,
                          result,
                          [UnityParty zny_urlEncode:strData],
                          [UnityParty zny_urlEncode:sign]
                          ];
    
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    if (self.timeout >0) {
        [request setTimeoutInterval:self.timeout];
    }
    
    [request setHTTPMethod:@"POST"];
    
    [request setHTTPBody:[httpBody dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData *data, NSURLResponse* response, NSError* error) {
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    if (data != nil) {
                                                        //接受到数据，表示工作正常
                                                        NSDictionary *rspDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                                                        
                                                        NSNumber* rspResult = [rspDict objectForKey:@"ret"];
                                                        if (rspResult == nil) {
                                                            onFail(RESULT_EXCEPTION);
                                                            return;
                                                        }
                                                        
                                                        if ([rspResult intValue] != 0) {
                                                            onFail([rspResult intValue]);
                                                            return;
                                                        }
                                                        
                                                        NSString *sign = [rspDict objectForKey:@"sign"];
                                                        NSString *calcSign = [UnityParty zny_genMD5:[NSString stringWithFormat:@"%@|%@|%d|%@",
                                                                                        self.secret, urlPath, bellID, rspResult]];
                                                        
                                                        if ([calcSign isEqualToString:sign]) {
                                                            onSucc();
                                                        }
                                                        else {
                                                            onFail(RESULT_SIGN_INVALID);
                                                        }
                                                        
                                                    }
                                                    else{
                                                        if (error != nil) {
                                                            NSLog(@"http fail, url: %@, error: %@", strUrl, [error localizedDescription]);
                                                        }
                                                        else {
                                                            NSLog(@"http fail, url: %@", strUrl);
                                                        }
                                                        
                                                        onFail(RESULT_HTTP_FAIL);
                                                    }
                                                });
                                        }
    ];
    
    [task resume];
    
    [self zny_addTask:task];
}


-(NSString*)zny_genUrl: (NSString*)path {
    return [NSString stringWithFormat:@"%@://%@%@", self.scheme, self.host, path];
}

-(NSString*)zny_genHttpUrl: (NSString*)path {
    return [NSString stringWithFormat:@"%@://%@%@", SCHEME_HTTP, self.host, path];
}

-(void)zny_addTask: (NSURLSessionDataTask*)task {
    [self.taskQueue addObject:task];
    
    // 删除所有状态为已完成的task
    // 不在回调里面直接remove的原因是会崩溃，就跟java的编译错误一样
    for (int i=0; i < self.taskQueue.count; ) {
        NSURLSessionDataTask* tmpTask = self.taskQueue[i];
        
        if (tmpTask && tmpTask.state == NSURLSessionTaskStateCompleted) {
            [self.taskQueue removeObjectAtIndex:i];
        }
        else {
            ++ i;
        }
    }
    
    // 清理超过大小的task
    while (self.taskQueueMaxSize > 0 && self.taskQueue.count > self.taskQueueMaxSize) {
        NSURLSessionDataTask* tmpTask = self.taskQueue[0];
        // 删掉开头的那个
        [self.taskQueue removeObjectAtIndex:0];
        
        [self zny_freeTask:tmpTask];
    }
}

-(void)zny_freeTask:(NSURLSessionDataTask*)task {
    if (task.state != NSURLSessionTaskStateCompleted && task.state != NSURLSessionTaskStateCanceling) {
        [task cancel];
    }
}

+(NSString*)zny_base64DecodeWithString:(NSString*)path {
    // 解密
    NSData *resultData = [[NSData alloc] initWithBase64EncodedString:path options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSString *result_path = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
    return result_path;
}

@end
