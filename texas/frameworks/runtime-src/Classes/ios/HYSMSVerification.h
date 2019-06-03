//
//  HYSMSVerification.h
//  texas
//
//  Created by lynn on 16/5/16.
//
//

#ifndef __SMS_VERIFICATION_H__
#define __SMS_VERIFICATION_H__

@interface HYSMSVerification : NSObject


+ (void)zny_initWithKey : (NSString *)key
          AndSecret : (NSString *)secret;

+ (void)zny_getSMSVerificationCode: (NSString *)zoneCode
                  phoneNum : (NSString *)phone
                luaCallback:(int)cb;

+ (void)zny_getVoiceVerificationCode: (NSString *)zoneCode
                     phoneNum : (NSString *)phone
                   luaCallback:(int)cb;

+ (void)zny_excuteLuaCallback : (bool)success
                   reason : (NSString*)message;

+ (bool)zny_isEnabled;

@end


#endif /* __SMS_VERIFICATION_H__ */
