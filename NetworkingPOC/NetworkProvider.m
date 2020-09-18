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
#include <ifaddrs.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <sys/ioctl.h>
#include <net/if.h>

@implementation NetworkProvider{
    CWInterface *interface;
    CFArrayRef allInterfaces;
    
    NSString *ssid;
    NSString *interfaceName;
    long interfaceMode;
    double TxRate;
    long signalStrength;
    NSString *activeStatus;
    NSString *security;
    long channelNo;
    long noiseMeasurement;
    NSString *routerString;
}

- (id)init {
    
    self = [super init];
    interface = [[CWWiFiClient sharedWiFiClient]interface];
    allInterfaces = SCNetworkInterfaceCopyAll();
    return self;
}

- (void)getWifiInfo {
    
    /* SSID*/
    ssid = [interface ssid];
    if(!ssid)
        ssid = @"NA";
    
    interfaceName = [interface interfaceName];
    
    /* returns ssid, bssid, security type, rssi, channel, channel width, ibss*/
//    NSLog(@"Networks With SSID :- %@",[interface scanForNetworksWithSSID:[interface ssidData] includeHidden:YES error:nil]);
//    NSLog(@"scanForNetworksWithName - %@",[[wifiManager interface]scanForNetworksWithName:@"ZTE-3F5sGd" includeHidden:YES error:nil]);
    
    interfaceMode = (long)[interface interfaceMode];
 
    TxRate = [interface transmitRate];
    
    signalStrength = (long)[interface rssiValue];
    
    activeStatus = [interface serviceActive]?@"Active":@"Inactive";
    
    switch ([interface security]) {
        case kCWSecurityWPA2Personal:
            security = @"Security WPA2 Personal";
            break;
        case kCWSecurityWPAPersonal:
            security = @"Security WPA Personal";
            break;
        case kCWSecurityWPAPersonalMixed:
            security = @"Security WPA/WPA2 Personal";
            break;
        case kCWSecurityWPAEnterprise:
            security = @"Security WPA Enterprise";
            break;
        case kCWSecurityWPA2Enterprise:
            security = @"Security WPA2 Enterprise";
            break;
        case kCWSecurityWPAEnterpriseMixed:
            security = @"Security WPA/WPA2 Enterprise";
            break;
        case kCWSecurityNone:
            security = @"Security NONE";
            break;
        case kCWSecurityUnknown:
            security = @"Security Unkonown";
            break;
        default:
            security = [NSString stringWithFormat:@"Security %ld",(long)[interface security]];
            break;
    }
    
    CWChannel *channel = [interface wlanChannel];
    channelNo = [channel channelNumber];

//    NSLog(@"Channel Band - %ld",(long)[channel channelBand]);
//    NSLog(@"Channel Width - %ld",(long)[channel channelWidth]);
    
    noiseMeasurement = (long)[interface noiseMeasurement];
    

    /* Router Address*/
    routerString = @"NA";
    SCDynamicStoreRef ds = SCDynamicStoreCreate(kCFAllocatorDefault, CFSTR("myapp"), NULL, NULL);
    CFDictionaryRef dr = SCDynamicStoreCopyValue(ds, CFSTR("State:/Network/Global/IPv4"));
    if (!dr)
        return;
    CFStringRef router = CFDictionaryGetValue(dr, CFSTR("Router"));
    routerString = [NSString stringWithString:(__bridge NSString *)router];
    if(!routerString)
        routerString = @"NA";
    CFRelease(dr);
    CFRelease(ds);

}

- (void)getInterfaceType {
    
    NSMutableArray *networkArray = [[NSMutableArray alloc]init];
    long count = CFArrayGetCount(allInterfaces);
    
    for(int i=0; i<count ;i++)
    {
        NSString *dictSsid = @"NA";
        NSString *dictInterfaceMode = @"NA";
        NSString *dictTxRate = @"NA";
        NSString *dictSignalStrength = @"NA";
        NSString *dictActiveStatus = @"NA";
        NSString *dictSecurity = @"NA";
        NSString *dictChannelNO = @"NA";
        NSString *dictNoiceMeasurement = @"NA";
        NSString *dictRouterAddress = @"NA";
        
        SCNetworkInterfaceRef interface = CFArrayGetValueAtIndex(allInterfaces, i);
        
        NSString *type = (NSString *)SCNetworkInterfaceGetInterfaceType(interface);
        
        NSString *localName = (NSString *)SCNetworkInterfaceGetLocalizedDisplayName(interface);
        
        NSString *bsdName = (NSString *)SCNetworkInterfaceGetBSDName(interface);
        
        /* Identifies all of the network interface types, such as PPP, that can be layered on top of the specified interface.*/
        NSString *supportInterfaceType = (NSString *)SCNetworkInterfaceGetSupportedInterfaceTypes(interface);
        if (!supportInterfaceType)
            supportInterfaceType=@"NA";
        
        /* Identifies all of the network protocol types, such as IPv4 and IPv6, that can be layered on top of the specified interface*/
        NSString *supportProtocolType = (NSString *)SCNetworkInterfaceGetSupportedProtocolTypes(interface);

        NSString *macAddress = (NSString *)SCNetworkInterfaceGetHardwareAddressString(interface);

        NSDictionary *bytesDict = [self getDataCounters:bsdName];
        NSString *bytesSent = @"NA";
        if ([bytesDict objectForKey:@"BytesSent"])
            bytesSent = [bytesDict objectForKey:@"BytesSent"];
        
        NSString *bytesReceived = @"NA";
        if ([bytesDict objectForKey:@"BytesReceived"])
            bytesReceived = [bytesDict objectForKey:@"BytesReceived"];
        
        NSString *packetsSent = @"NA";
        if ([bytesDict objectForKey:@"PacketsSent"])
            packetsSent = [bytesDict objectForKey:@"PacketsSent"];
        
        NSString *packetsReceived = @"NA";
        if ([bytesDict objectForKey:@"PacketsReceived"])
            packetsReceived = [bytesDict objectForKey:@"PacketsReceived"];
        
        char *ipv4 = getIpAddress((char *)[bsdName UTF8String],0);
        NSString *ipv4addr = [NSString stringWithFormat:@"%s" , ipv4];
        
        char *ipv6 = getIpAddress((char *)[bsdName UTF8String],1);
        NSString *ipv6addr = [NSString stringWithFormat:@"%s" , ipv6];
        
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        [dict setObject:type forKey:@"Interface Type"];
        [dict setObject:localName forKey:@"Local Name"];
        [dict setObject:bsdName forKey:@"BSD Name"];
        [dict setObject:supportInterfaceType forKey:@"Support Interface Type"];
        [dict setObject:supportProtocolType forKey:@"Support Protocol Type"];
        [dict setObject:macAddress forKey:@"Hardware Address"];
        [dict setObject:bytesSent forKey:@"Bytes Sent"];
        [dict setObject:bytesReceived forKey:@"Bytes Received"];
        [dict setObject:ipv4addr forKey:@"IPV4"];
        [dict setObject:ipv6addr forKey:@"IPV6"];
        [dict setObject:packetsSent forKey:@"Packets Sent"];
        [dict setObject:packetsReceived forKey:@"Packets Received"];
        
        if ([bsdName isEqualToString:interfaceName]) {

            dictSsid = ssid;
            dictInterfaceMode = [NSString stringWithFormat:@"%ld",interfaceMode];
            dictTxRate = [NSString stringWithFormat:@"%fd",TxRate];
            dictSignalStrength = [NSString stringWithFormat:@"%ld",signalStrength];
            dictActiveStatus = activeStatus;
            dictSecurity = security;
            dictChannelNO = [NSString stringWithFormat:@"%ld",channelNo];
            dictNoiceMeasurement = [NSString stringWithFormat:@"%ld",noiseMeasurement];
            dictRouterAddress = routerString;
        }
        
        [dict setObject:dictSsid forKey:@"ssid"];
        [dict setObject:dictInterfaceMode forKey:@"interface mode"];
        [dict setObject:dictTxRate forKey:@"TxRate"];
        [dict setObject:dictSignalStrength forKey:@"Signal Strength"];
        [dict setObject:dictActiveStatus forKey:@"Status"];
        [dict setObject:dictSecurity forKey:@"Security Type"];
        [dict setObject:dictChannelNO forKey:@"Channel no"];
        [dict setObject:dictNoiceMeasurement forKey:@"Noice Measurement"];
        [dict setObject:dictRouterAddress forKey:@"Router Address"];
        [networkArray addObject:dict];
    }
    
    NSMutableDictionary *payloadDict = [[NSMutableDictionary alloc]init];
    [payloadDict  setObject:@"1.0" forKey:@"Version"];
    [payloadDict setObject:[self getTime] forKey:@"Date Time"];
    
    [payloadDict setObject:networkArray forKey:@"Network List"];
    NSLog(@"payload dict %@",payloadDict);
    NSError * err;
    NSData * jsonData = [NSJSONSerialization  dataWithJSONObject:payloadDict options:0 error:&err];
    NSString * payloadJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"Final Payload %@",payloadJson);
}

-(NSString *)getTime{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSString *dateString = nil;
    @try{
        dateFormatter.dateFormat = @"yyyyMMdd'T'HHmmss";
    dateString = [dateFormatter stringFromDate:NSDate.date];
    } @catch (NSException *exception){
        NSLog(@"Exception : %@", [exception description]);
        return nil;
    }
    return dateString;
}

static char * getIpAddress(char *interface, bool value)
{
    char *name = interface;
    struct ifaddrs *myaddrs, *ifa;
    void *in_addr;
    char buf[64];

    if(getifaddrs(&myaddrs) != 0)
    {
        perror("getifaddrs");
        exit(1);
    }

    for (ifa = myaddrs; ifa != NULL; ifa = ifa->ifa_next)
    {
        if (strcmp(name, ifa->ifa_name)) {
        continue;
        };
        if (ifa->ifa_addr == NULL)
            continue;
        if (!(ifa->ifa_flags & IFF_UP))
            continue;

        if (ifa->ifa_addr->sa_family == AF_INET && value == 0 ){
            struct sockaddr_in *s4 = (struct sockaddr_in *)ifa->ifa_addr;
            in_addr = &s4->sin_addr;
        }
        else if (ifa->ifa_addr->sa_family == AF_INET6 && value == 1){
            struct sockaddr_in6 *s6 = (struct sockaddr_in6 *)ifa->ifa_addr;
            in_addr = &s6->sin6_addr;
        }
        else{
            continue;
        }

        inet_ntop(ifa->ifa_addr->sa_family, in_addr, buf, sizeof(buf));
        freeifaddrs(myaddrs);
        return  buf;
        }
    freeifaddrs(ifa);
    freeifaddrs(myaddrs);
    return  NULL;
}

- (NSDictionary *)getDataCounters :(NSString *)bsdName
{
    BOOL   success;
    struct ifaddrs *addrs;
    const struct ifaddrs *cursor;
    const struct if_data *networkStatisc;

    int bytesSent = 0;
    int bytesReceived = 0;
    int packetsSent = 0;
    int packetsReceived = 0;

    NSString *name=[[NSString alloc]init];

    success = getifaddrs(&addrs) == 0;
    if (success)
    {
        cursor = addrs;
        while (cursor != NULL)
        {
            name=[NSString stringWithFormat:@"%s",cursor->ifa_name];

            if (cursor->ifa_addr->sa_family == AF_LINK)
            {
                if ([name isEqualToString:bsdName])
                {
                    networkStatisc = (const struct if_data *) cursor->ifa_data;
                    bytesSent = networkStatisc->ifi_obytes;
                    bytesReceived = networkStatisc->ifi_ibytes;
                    packetsSent = networkStatisc->ifi_opackets;
                    packetsReceived = networkStatisc->ifi_ipackets;
                    return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:bytesSent],@"BytesSent",[NSNumber numberWithInt:bytesReceived],@"BytesReceived",[NSNumber numberWithInt:packetsSent],@"PacketsSent",[NSNumber numberWithInt:packetsReceived],@"PacketsReceived", nil];
                }
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }
    return [[NSDictionary alloc]init];
}

@end
