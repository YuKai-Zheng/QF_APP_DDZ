#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

#import "UnityApplePartyDelegate.h"
#import "UnityPartyBellParams.h"

@interface UnityApplePartySKProductsRequest : NSObject<SKProductsRequestDelegate>

-(id)init: (id<UnityApplePartyDelegate>)applePartyDelegate bellParams:(UnityPartyBellParams*)bellParams
 onResult: (UNITY_PARTY_RESULT_CALLBACK)onResult;

@end
