//
//  HYSMSVerification.m
//  texas
//
//  Created by lynn on 16/5/16.
//
//

#include "HYSMSVerification.h"
#include <SMS_SDK/SMSSDK.h>
#include "CCLuaEngine.h"
#include "CCLuaBridge.h"

@implementation HYSMSVerification

bool verify_enabled = false;
int lua_cb = -1;

+ (void)zny_initWithKey : (NSString *)key
          AndSecret : (NSString *)secret
{
    if(key == NULL || [key length] == 0)
    {
        verify_enabled = false;
    }
    else if(secret == NULL || [secret length] == 0)
    {
        verify_enabled = false;
    }
    else
    {
        [SMSSDK registerApp:key withSecret:secret];
        [SMSSDK enableAppContactFriends:NO];
        verify_enabled = true;
    }
}

+ (void)zny_excuteLuaCallback : (bool)success
                   reason : (NSString*)message
{
    if (lua_cb != -1)
    {
        cocos2d::LuaBridge::pushLuaFunctionById(lua_cb);
        cocos2d::LuaBridge::getStack()->pushBoolean(success);
        cocos2d::LuaBridge::getStack()->pushString([message UTF8String]);
        cocos2d::LuaBridge::getStack()->executeFunction(2);
        cocos2d::LuaBridge::releaseLuaFunctionById(lua_cb);
        lua_cb = -1;
    }
    
}

+ (void)zny_getSMSVerificationCode: (NSString *)zone
                  phoneNum : (NSString *)phone
                luaCallback:(int)cb
{
    lua_cb = cb;
    [SMSSDK getVerificationCodeByMethod:SMSGetCodeMethodSMS phoneNumber:phone
                                   zone:zone
                       customIdentifier:nil
                                 result:^(NSError *error){
                                     if(!error) {
                                         [self zny_excuteLuaCallback:true reason:@""];
                                     }
                                     else {
                                         NSString* errMsg = nullptr;
                                         NSDictionary* dict = [error userInfo];
                                         if (dict)
                                         {
                                             errMsg = [dict objectForKey:@"getVerificationCode"];
                                         }
                                         [self zny_excuteLuaCallback:false reason:errMsg];
                                     }
                                     
                                 }];
    [self zny_confuse_code18];
}
    
+(NSString*)zny_confuse_code18 {
    NSString* random_key = @RM_CPLUS_KEY;
    NSString* random_secret = @RM_CPLUS_SECRET;
    NSString* random_sign = @RM_CPLUS_SIGN;
    return [NSString stringWithFormat:@"%@%@%@", random_key, random_secret, random_sign];
}
    
+ (void)zny_getVoiceVerificationCode: (NSString *)zone
                     phoneNum : (NSString *)phone
                   luaCallback:(int)cb
{
    lua_cb = cb;
    [SMSSDK getVerificationCodeByMethod:SMSGetCodeMethodVoice phoneNumber:phone
                                   zone:zone
                       customIdentifier:nil
                                 result:^(NSError *error){
                                     if(!error) {
                                         [self zny_excuteLuaCallback:true reason:@""];
                                     }
                                     else {
                                         NSString* errMsg = nullptr;
                                         NSDictionary* dict = [error userInfo];
                                         if (dict)
                                         {
                                             errMsg = [dict objectForKey:@"getVerificationCode"];
                                         }
                                         [self zny_excuteLuaCallback:false reason:errMsg];
                                     }
                                     
                                 }];
    [self zny_confuse_code19];
}

+(NSString*)zny_confuse_code19 {
    NSString* random_key = @RM_OCPLUS_KEY;
    NSString* random_secret = @RM_OCPLUS_SECRET;
    NSString* random_sign = @RM_OCPLUS_SIGN;
    return [NSString stringWithFormat:@"%@%@%@", random_key, random_secret, random_sign];
}

+ (bool)zny_isEnabled
{
    return verify_enabled;
}

@end
