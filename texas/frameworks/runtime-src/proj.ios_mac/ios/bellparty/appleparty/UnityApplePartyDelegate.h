
/*
 当苹果支付sdk调用有结果后，要进行回调
*/

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "UnityPartyBellParams.h"
#import "UnityParty.h"


@protocol UnityApplePartyDelegate <NSObject>

-(void) zny_onGetProductResult: (id)delegate product:(SKProduct*)product bellParams:(UnityPartyBellParams*)bellParams
onResult: (UNITY_PARTY_RESULT_CALLBACK)onResult;

@end
