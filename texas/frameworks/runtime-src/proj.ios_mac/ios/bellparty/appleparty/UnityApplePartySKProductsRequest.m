#import "UnityApplePartySKProductsRequest.h"


@interface UnityApplePartySKProductsRequest()

@property (nonatomic, strong) id<UnityApplePartyDelegate> applePartyDelegate;
@property (nonatomic, strong) UnityPartyBellParams* bellParams;
@property (nonatomic, strong) UNITY_PARTY_RESULT_CALLBACK onResult;


@end

@implementation UnityApplePartySKProductsRequest

-(id)init: (id<UnityApplePartyDelegate>)applePartyDelegate bellParams:(UnityPartyBellParams*)bellParams
 onResult: (UNITY_PARTY_RESULT_CALLBACK)onResult {
    
    if (self = [super init]) {
        self.applePartyDelegate = applePartyDelegate;
        self.bellParams = bellParams;
        self.onResult = onResult;
    
    }
    
    return self;
}

// 查询成功后的回调
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {

    if (response.products.count == 0) {
        NSLog(@"response.products.count == 0");
        [self.applePartyDelegate zny_onGetProductResult:self product:nil bellParams:self.bellParams onResult:self.onResult];
        return;
    }
    else {
        [self.applePartyDelegate zny_onGetProductResult:self product:response.products[0] bellParams:self.bellParams onResult:self.onResult];
    }

}

//查询失败后的回调
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"get product fail. error: %@", error);
    
    [self.applePartyDelegate zny_onGetProductResult:self product:nil bellParams:self.bellParams onResult:self.onResult];
}

@end
