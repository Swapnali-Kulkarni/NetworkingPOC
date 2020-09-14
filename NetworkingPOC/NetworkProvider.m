//
//  NetworkProvider.m
//  NetworkingPOC
//
//  Created by Swapnali Kulkarni on 31/08/20.
//  Copyright © 2020 Swapnali Kulkarni. All rights reserved.
//

#import "NetworkProvider.h"
#import <CoreWLAN/CWWiFiClient.h>
#import <CoreWLAN/CoreWLAN.h>
#import <SystemConfiguration/SCNetworkConfiguration.h>
#include <stdio.h>
#include <SystemConfiguration/SystemConfiguration.h>

@implementation NetworkProvider{
    CWInterface *interface;
    CFArrayRef allInterfaces;
}

- (id)init {
    
    self = [super init];
    interface = [[CWWiFiClient sharedWiFiClient]interface];
    allInterfaces = SCNetworkInterfaceCopyAll();
    return self;
}

- (void)getNetworkInfo {
    
    /* SSID*/
    NSString *ssid = [interface ssid];
    NSLog(@"SSID :- %@",ssid);
    
    /* returns ssid, bssid, security type, rssi, channel, channel width, ibss*/
//    NSLog(@"Networks With SSID :- %@",[interface scanForNetworksWithSSID:[interface ssidData] includeHidden:YES error:nil]);
//    NSLog(@"scanForNetworksWithName - %@",[[wifiManager interface]scanForNetworksWithName:@"ZTE-3F5sGd" includeHidden:YES error:nil]);
    
    /* current mode for the interface */
    NSLog(@"interfaceMode :- %ld",(long)[interface interfaceMode]);
 
    /* Transmition Rate */
    double TxRate = [interface transmitRate];
    NSLog(@"TxRate :- %f",TxRate);
    NSLog(@"Received Signal strength :- %ld",(long)[interface rssiValue]);
    NSLog(@"Service Active Status :- %@",[interface serviceActive]?@"Active":@"Inactive");
    
    /* Security Type */
    switch ([interface security]) {
        case kCWSecurityWPA2Personal:
            NSLog(@"Security WPA2 Personal");
            break;
        case kCWSecurityWPAPersonal:
            NSLog(@"Security WPA Personal");
            break;
        case kCWSecurityWPAPersonalMixed:
            NSLog(@"Security WPA/WPA2 Personal");
            break;
        case kCWSecurityWPAEnterprise:
            NSLog(@"Security WPA Enterprise");
            break;
        case kCWSecurityWPA2Enterprise:
            NSLog(@"Security WPA2 Enterprise");
            break;
        case kCWSecurityWPAEnterpriseMixed:
            NSLog(@"Security WPA/WPA2 Enterprise");
            break;
        case kCWSecurityNone:
            NSLog(@"Security NONE");
            break;
        case kCWSecurityUnknown:
            NSLog(@"Security Unkonown");
            break;
        default:
            NSLog(@"Security %ld",(long)[interface security]);
            break;
    }
    
    /* WALN Channel */
    CWChannel *channel = [interface wlanChannel];
    long channelNo = [channel channelNumber];
    NSLog(@"Channel Number :- %ld",channelNo);

//    NSLog(@"Channel Band - %ld",(long)[channel channelBand]);
//    NSLog(@"Channel Width - %ld",(long)[channel channelWidth]);
    
    /* Noise Measurement*/
    NSLog(@"noiseMeasurement :- %ld",(long)[interface noiseMeasurement]);
    
}

- (void)defaultRouter {

    /* Router Address*/
    SCDynamicStoreRef ds = SCDynamicStoreCreate(kCFAllocatorDefault, CFSTR("myapp"), NULL, NULL);
    CFDictionaryRef dr = SCDynamicStoreCopyValue(ds, CFSTR("State:/Network/Global/IPv4"));
    if (!dr)
        return;
    CFStringRef router = CFDictionaryGetValue(dr, CFSTR("Router"));
    NSString *routerString = [NSString stringWithString:(__bridge NSString *)router];
    CFRelease(dr);
    CFRelease(ds);

    NSLog(@"Router :- %@",routerString);
}

- (void)getInterfaceType {
    
    long count = CFArrayGetCount(allInterfaces);
    
    for(int i=0; i<count ;i++)
    {
        SCNetworkInterfaceRef interface = CFArrayGetValueAtIndex(allInterfaces, i);
        NSLog(@"----");
        
        NSString *type = (NSString *)SCNetworkInterfaceGetInterfaceType(interface);
        NSLog(@"Interface Type - %@",type);
        
        //-----------//
        NSString *localName = (NSString *)SCNetworkInterfaceGetLocalizedDisplayName(interface);
        NSLog(@"Local Name - %@",localName);
        
        
        NSString *bsdName = (NSString *)SCNetworkInterfaceGetBSDName(interface);
        NSLog(@"Interface BSD Name - %@",bsdName);
        
        NSString *serviceName = (NSString *)SCNetworkServiceGetName((SCNetworkServiceRef)interface);
        NSLog(@"Service Name - %@",serviceName);
        
        /* Identifies all of the network interface types, such as PPP, that can be layered on top of the specified interface.*/
        NSLog(@"Support Interface Types %@",SCNetworkInterfaceGetSupportedInterfaceTypes(interface));

        /* Identifies all of the network protocol types, such as IPv4 and IPv6, that can be layered on top of the specified interface*/
        NSLog(@"Support Protocol Types %@",SCNetworkInterfaceGetSupportedProtocolTypes(interface));

        /* Hardware Address*/
        NSLog(@"Hardware Address - %@",SCNetworkInterfaceGetHardwareAddressString(interface));

        //-----------//
        SCNetworkConnectionRef connection = NULL;
        NSLog(@"Connection Status - %d",SCNetworkConnectionGetStatus(connection));
        
        
//        CFDictionaryRef *current = NULL;
//        CFDictionaryRef  _Nullable *active = NULL;
//        CFArrayRef  _Nullable *available = NULL;
//        SCNetworkInterfaceCopyMediaOptions(interface,current,active, available,TRUE);
//        NSLog(@"current %@,\n active %@,\n available %@",current,active,available);
    }
    
    /* Returns the type identifier of all SCNetworkInterface instances.*/
    NSLog(@"interface get type id %lu",SCNetworkInterfaceGetTypeID());

}

@end
