/*
 注意: bellParams.extra 增加:
    item_code: 苹果支付申请的计费点
 */


#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

#import "UnityParty.h"
#import "UnitySDKParty.h"
#import "UnityApplePartyDelegate.h"


@interface UnityAppleParty : NSObject<UnitySDKParty, UnityApplePartyDelegate, SKPaymentTransactionObserver>


@property (nonatomic, strong, readonly) UnityParty* unityParty;

-(id)init: (NSString*)host source: (NSString*)source secret: (NSString*) secret;

// onResult: result, bill_id
-(void)zny_party: (UnityPartyBellParams*)bellParams onResult: (UNITY_PARTY_RESULT_CALLBACK)onResult;


@end
