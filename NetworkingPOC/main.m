//
//  main.m
//  NetworkingPOC
//
//  Created by Swapnali Kulkarni on 31/08/20.
//  Copyright © 2020 Swapnali Kulkarni. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkProvider.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NetworkProvider *network = [[NetworkProvider alloc]init];
        [network transmissionData];
        [network getInterfaceType];
        }
    return 0;
}
