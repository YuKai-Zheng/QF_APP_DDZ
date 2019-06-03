//
//  UnitySDKPayFactory.h
//  texas
//
//  Created by Jiangliwu on 14/12/9.
//
//

@interface UnitySDKPartyFactory : NSObject{
    
}

+ (id)getInstance;
- (void)zny_startParty:(NSDictionary*)args;
- (void)zny_initParty;

@end
