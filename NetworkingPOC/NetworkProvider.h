//
//  NetworkProvider.h
//  NetworkingPOC
//
//  Created by Swapnali Kulkarni on 31/08/20.
//  Copyright © 2020 Swapnali Kulkarni. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NetworkProvider : NSObject
- (void)getNetworkInfo;
- (void)getInterfaceType;
- (void)defaultRouter;

@end

NS_ASSUME_NONNULL_END
