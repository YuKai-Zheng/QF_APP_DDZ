#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "UnityPartyBellParams.h"
#import "UnityParty.h"


@protocol UnitySDKParty <NSObject>

@required
-(void)zny_party: (UnityPartyBellParams*)bellParams onResult: (UNITY_PARTY_RESULT_CALLBACK)onResult;

@end
