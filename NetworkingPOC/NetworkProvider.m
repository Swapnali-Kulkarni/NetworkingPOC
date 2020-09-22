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
#include <sys/sysctl.h>
#include <netinet/in.h>
#include <net/route.h>

#define SSID_KEY @"SSID"
#define INTERFACE_NAME_KEY @"Interface Name"
#define INTERFACE_MODE_KEY @"Interface Mode"
#define TXRATE_KEY @"TxRate"
#define SIGNAL_STRENGTH_KEY @"Signal Strength"
#define SECURITY_KEY @"Security Type"
#define CHANNEL_NO_KEY @"Channel No"
#define CHANNEl_BAND_KEY @"Channel Band"
#define CHANNEL_WIDTH_KEY @"Channel Width"
#define NOISE_MEASUREMENT_KEY @"Noise Measurement"
#define ROUTER_ADDRESS_KEY @"Router Address"
#define COUNTRY_CODE_KEY @"Country Code"
#define WIFI_POWER_STATUS_KEY @"wifi power status"
#define TRANSMIT_POWER_KEY @"Transmit Power"
#define ACTIVE_PHY_MODE_KEY @"Active PHY Mode"
#define INTERFACE_TYPE @"Interface Type"
#define LOCAL_NAME @"Local Name"
#define BSD_NAME @"BSD Name"
#define BYTES_SENT @"Bytes Sent"
#define BYTES_RECEIVED @"Bytes Received"
#define PACKETS_SENT @"Packets Sent"
#define PACKETS_RECEIVED @"Packets Received"
#define LINK_SPEED @"Link Speed"
#define ERROR_RECEIVED @"Error Received"
#define ERROR_SENT @"Error Sent"
#define PACKETS_SENT_MULTICAST @"Packets Sent Multicast"
#define PACKETS_RECEIVED_MULTICAST @"Packets Received Multicast"
#define SUPPORT_INTERFACE_TYPE @"Support Interface Type"
#define SUPPORT_PROTOCOL_TYPE @"Support Protocol Type"
#define HARDWARE_ADDRESS @"Hardware Address"
#define IPV4 @"IPV4"
#define IPV6 @"IPV6"

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

- (NSDictionary *)getWifiInfo {
        
    NSMutableDictionary *wifiInfo = [[NSMutableDictionary alloc]init];
    
    /* SSID of router */
    NSString *ssid = [interface ssid];
    if(!ssid)
        ssid = @"NA";
    [wifiInfo setObject:ssid forKey:SSID_KEY];
    
    /* Interface name i.e. bsd name*/
    NSString *interfaceName = [interface interfaceName];
    [wifiInfo setObject:interfaceName forKey:INTERFACE_NAME_KEY];
    
    /* Returns the current operating mode for the Wi-Fi interface */
    long interfaceMode = (long)[interface interfaceMode];
    [wifiInfo setObject:[NSString stringWithFormat:@"%ld",interfaceMode] forKey:INTERFACE_MODE_KEY];

    /* Transmission Rate of wifi */
    double TxRate = [interface transmitRate];
    [wifiInfo setObject:[NSString stringWithFormat:@"%f",TxRate] forKey:TXRATE_KEY];
    
    /* current transmit power (mW) for the Wi-Fi interface.*/
     long transmitPower = [interface transmitPower];
     [wifiInfo setObject:[NSString stringWithFormat:@"%ld",transmitPower] forKey:TRANSMIT_POWER_KEY];

    /* Current received signal strength indication (RSSI) measurement (dBm) for the Wi-Fi interface. */
    long signalStrength = (long)[interface rssiValue];
    [wifiInfo setObject:[NSString stringWithFormat:@"%ld",signalStrength] forKey:SIGNAL_STRENGTH_KEY];

    CWChannel *channel = [interface wlanChannel];
    long channelNo = [channel channelNumber];
    [wifiInfo setObject:[NSString stringWithFormat:@"%ld",channelNo] forKey:CHANNEL_NO_KEY];

    long channelBand  = [channel channelBand];
    [wifiInfo setObject:[NSString stringWithFormat:@"%ld",channelBand] forKey:CHANNEl_BAND_KEY];

    long channelWidth = [channel channelWidth];
    [wifiInfo setObject:[NSString stringWithFormat:@"%ld",channelWidth] forKey:CHANNEL_WIDTH_KEY];

    /* current noise measurement (dBm) for the Wi-Fi interface.*/
    long noiseMeasurement = (long)[interface noiseMeasurement];
    [wifiInfo setObject:[NSString stringWithFormat:@"%ld",noiseMeasurement] forKey:NOISE_MEASUREMENT_KEY];

    /* currently adopted country code (ISO/IEC 3166-1:1997) for the Wi-Fi interface.*/
    NSString *countryCode = [interface countryCode]?[interface countryCode]:@"NA";
    [wifiInfo setObject:countryCode forKey:COUNTRY_CODE_KEY];
    
    /* Indicates the Wi-Fi interface power state. wifi is on or off */
    NSString *wifiPowerStatus = [interface powerOn]?@"ON":@"OFF";
    [wifiInfo setObject:wifiPowerStatus forKey:WIFI_POWER_STATUS_KEY];
    
    /* currently active physical layer (PHY) mode of the Wi-Fi interface. if wifi is off returns 0*/
    long activePHYMode = [interface activePHYMode];
    [wifiInfo setObject:[NSString stringWithFormat:@"%ld",activePHYMode] forKey:ACTIVE_PHY_MODE_KEY];

    /* Security type of wifi interface*/
    NSString *security;
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
    [wifiInfo setObject:security forKey:SECURITY_KEY];
    
    /* Router Address*/
    NSString *routerString = @"NA";
    SCDynamicStoreRef ds = SCDynamicStoreCreate(kCFAllocatorDefault, CFSTR("myapp"), NULL, NULL);
    CFDictionaryRef dr = SCDynamicStoreCopyValue(ds, CFSTR("State:/Network/Global/IPv4"));
    if (dr){
        CFStringRef router = CFDictionaryGetValue(dr, CFSTR("Router"));
        routerString = [NSString stringWithString:(__bridge NSString *)router];
        if(!routerString)
            routerString = @"NA";
        CFRelease(dr);
    }
    CFRelease(ds);
    [wifiInfo setObject:routerString forKey:ROUTER_ADDRESS_KEY];

    return wifiInfo;
}

- (void)getInterfaceType {
    
    NSDictionary *wifiInfo = [self getWifiInfo];
    
    NSMutableArray *networkArray = [[NSMutableArray alloc]init];
    long count = CFArrayGetCount(allInterfaces);
    
    for(int i=0; i<count ;i++)
    {
        NSString *dictSsid = @"NA";
        NSString *dictInterfaceMode = @"NA";
        NSString *dictTxRate = @"NA";
        NSString *dictSignalStrength = @"NA";
        NSString *dictSecurity = @"NA";
        NSString *dictChannelNO = @"NA";
        NSString *dictChannelBand = @"NA";
        NSString *dictChannelWidth = @"NA";
        NSString *dictNoiceMeasurement = @"NA";
        NSString *dictRouterAddress = @"NA";
        NSString *dictCountryCode = @"NA";
        NSString *dictWifiPowerStatus = @"NA";
        NSString *dictTransmitPower = @"NA";
        NSString *dictActivePHYMode = @"NA";

        
        SCNetworkInterfaceRef interface = CFArrayGetValueAtIndex(allInterfaces, i);
        
        /* Specifies the interface type. eg. IEEE80211 */
        NSString *type = (NSString *)SCNetworkInterfaceGetInterfaceType(interface);
        
        /* local name of particular interface */
        NSString *localName = (NSString *)SCNetworkInterfaceGetLocalizedDisplayName(interface);
        
        /* BSD name of particular interface. eg. en0, en1, bridge0,...*/
        NSString *bsdName = (NSString *)SCNetworkInterfaceGetBSDName(interface);
        
        /* Identifies all of the network interface types, such as PPP, that can be layered on top of the specified interface.*/
        NSString *supportInterfaceType = (NSString *)SCNetworkInterfaceGetSupportedInterfaceTypes(interface);
        if (!supportInterfaceType)
            supportInterfaceType=@"NA";
        
        /* Identifies all of the network protocol types, such as IPv4 and IPv6, that can be layered on top of the specified interface*/
        NSString *supportProtocolType = (NSString *)SCNetworkInterfaceGetSupportedProtocolTypes(interface);

        /* Hardware address of particular interface */
        NSString *macAddress = (NSString *)SCNetworkInterfaceGetHardwareAddressString(interface);

        NSDictionary *bytesDict = [self getDataCounters:bsdName];
            
        /* Number of bytes sent by the interface, since system started */
        NSString *bytesSent = [bytesDict objectForKey:BYTES_SENT]?[bytesDict objectForKey:BYTES_SENT]:@"NA";
        
        /* Number of bytes received by the interface, since system started */
        NSString *bytesReceived = [bytesDict objectForKey:BYTES_RECEIVED]?[bytesDict objectForKey:BYTES_RECEIVED]:@"NA";
        
        /* Number of packets sent by the interface */
        NSString *packetsSent = [bytesDict objectForKey:PACKETS_SENT]?[bytesDict objectForKey:PACKETS_SENT]:@"NA";
        
        /* Number of packets received by the interface */
        NSString *packetsReceived = [bytesDict objectForKey:PACKETS_RECEIVED]?[bytesDict objectForKey:PACKETS_RECEIVED]:@"NA";
        
        /* link speed of perticular interfae */
        NSString *linkSpeed = [bytesDict objectForKey:LINK_SPEED]?[bytesDict objectForKey:LINK_SPEED]:@"NA";
        
        /* Error received by the innterface */
        NSString *errorReceived = [bytesDict objectForKey:ERROR_RECEIVED]?[bytesDict objectForKey:ERROR_RECEIVED]:@"NA";
        
        /* Error sent by the interface */
        NSString *errorSent = [bytesDict objectForKey:ERROR_SENT]?[bytesDict objectForKey:ERROR_SENT]:@"NA";
        
        /* packets received multicast */
        NSString *packetsReceivedMulticast = [bytesDict objectForKey:PACKETS_SENT_MULTICAST]?[bytesDict objectForKey:PACKETS_SENT_MULTICAST]:@"NA";
        
        /* packets sent multicast */
        NSString *packetsSentMulticast = [bytesDict objectForKey:PACKETS_RECEIVED_MULTICAST]?[bytesDict objectForKey:PACKETS_RECEIVED_MULTICAST]:@"NA";
        
        /* IPV4 address */
        char *ipv4 = getIpAddress((char *)[bsdName UTF8String],0);
        NSString *ipv4addr = [NSString stringWithFormat:@"%s" , ipv4];
        
        /* IPV6 address */
        char *ipv6 = getIpAddress((char *)[bsdName UTF8String],1);
        NSString *ipv6addr = [NSString stringWithFormat:@"%s" , ipv6];
        
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        [dict setObject:type forKey:INTERFACE_TYPE];
        [dict setObject:localName forKey:LOCAL_NAME];
        [dict setObject:bsdName forKey:BSD_NAME];
        [dict setObject:supportInterfaceType forKey:SUPPORT_INTERFACE_TYPE];
        [dict setObject:supportProtocolType forKey:SUPPORT_PROTOCOL_TYPE];
        [dict setObject:macAddress forKey:HARDWARE_ADDRESS];
        [dict setObject:bytesSent forKey:BYTES_SENT];
        [dict setObject:bytesReceived forKey:BYTES_RECEIVED];
        [dict setObject:ipv4addr forKey:IPV4];
        [dict setObject:ipv6addr forKey:IPV6];
        [dict setObject:packetsSent forKey:PACKETS_SENT];
        [dict setObject:packetsReceived forKey:PACKETS_RECEIVED];
        [dict setObject:linkSpeed forKey:LINK_SPEED];
        [dict setObject:errorReceived forKey:ERROR_RECEIVED];
        [dict setObject:errorSent forKey:ERROR_SENT];
        [dict setObject:packetsSentMulticast forKey:PACKETS_SENT_MULTICAST];
        [dict setObject:packetsReceivedMulticast forKey:PACKETS_RECEIVED_MULTICAST];
        
        if ([bsdName isEqualToString:[wifiInfo objectForKey:INTERFACE_NAME_KEY]]) {

            dictSsid = [wifiInfo objectForKey:SSID_KEY];
            dictInterfaceMode = [wifiInfo objectForKey:INTERFACE_MODE_KEY];
            dictTxRate = [wifiInfo objectForKey:TXRATE_KEY];
            dictSignalStrength = [wifiInfo objectForKey:SIGNAL_STRENGTH_KEY];
            dictSecurity = [wifiInfo objectForKey:SECURITY_KEY];
            dictChannelNO = [wifiInfo objectForKey:CHANNEL_NO_KEY];
            dictChannelBand = [wifiInfo objectForKey:CHANNEl_BAND_KEY];
            dictChannelWidth = [wifiInfo objectForKey:CHANNEL_WIDTH_KEY];
            dictNoiceMeasurement = [wifiInfo objectForKey:NOISE_MEASUREMENT_KEY];
            dictRouterAddress = [wifiInfo objectForKey:ROUTER_ADDRESS_KEY];
            dictCountryCode = [wifiInfo objectForKey:COUNTRY_CODE_KEY];
            dictWifiPowerStatus = [wifiInfo objectForKey:WIFI_POWER_STATUS_KEY];
            dictTransmitPower = [wifiInfo objectForKey:TRANSMIT_POWER_KEY];
            dictActivePHYMode = [wifiInfo objectForKey:ACTIVE_PHY_MODE_KEY];
        }
        
        [dict setObject:dictSsid forKey:SSID_KEY];
        [dict setObject:dictInterfaceMode forKey:INTERFACE_MODE_KEY];
        [dict setObject:dictTxRate forKey:TXRATE_KEY];
        [dict setObject:dictSignalStrength forKey:SIGNAL_STRENGTH_KEY];
        [dict setObject:dictSecurity forKey:SECURITY_KEY];
        [dict setObject:dictChannelNO forKey:CHANNEL_NO_KEY];
        [dict setObject:dictChannelBand forKey:CHANNEl_BAND_KEY];
        [dict setObject:dictChannelWidth forKey:CHANNEL_WIDTH_KEY];
        [dict setObject:dictNoiceMeasurement forKey:NOISE_MEASUREMENT_KEY];
        [dict setObject:dictRouterAddress forKey:ROUTER_ADDRESS_KEY];
        [dict setObject:dictCountryCode forKey:COUNTRY_CODE_KEY];
        [dict setObject:dictWifiPowerStatus forKey:WIFI_POWER_STATUS_KEY];
        [dict setObject:dictTransmitPower forKey:TRANSMIT_POWER_KEY];
        [dict setObject:dictActivePHYMode forKey:ACTIVE_PHY_MODE_KEY];
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
    int linkSpeed = 0;
    int errorReceived = 0;
    int errorSent = 0;
    int packetsReceivedMulticast = 0;
    int packetsSentMulticast = 0;

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
                    linkSpeed = networkStatisc->ifi_baudrate;
                    errorReceived = networkStatisc->ifi_ierrors;
                    errorSent = networkStatisc->ifi_oerrors;
                    packetsReceivedMulticast = networkStatisc->ifi_imcasts;
                    packetsSentMulticast = networkStatisc->ifi_omcasts;
                    
                    return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:bytesSent],BYTES_SENT,[NSNumber numberWithInt:bytesReceived],BYTES_RECEIVED,[NSNumber numberWithInt:packetsSent],PACKETS_SENT,[NSNumber numberWithInt:packetsReceived],PACKETS_RECEIVED,[NSNumber numberWithInt:linkSpeed],LINK_SPEED,[NSNumber numberWithInt:errorReceived],ERROR_RECEIVED,[NSNumber numberWithInt:errorSent],ERROR_SENT,[NSNumber numberWithInt:packetsSentMulticast],PACKETS_SENT_MULTICAST,[NSNumber numberWithInt:packetsReceivedMulticast],PACKETS_RECEIVED_MULTICAST, nil];
                }
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }
    return [[NSDictionary alloc]init];
}

- (void)transmissionData {
    

    int mib[] = {
        CTL_NET,
        PF_ROUTE,
        0,
        0,
        NET_RT_IFLIST2,
        0
    };
    
    size_t len;
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        fprintf(stderr, "sysctl: %s\n", strerror(errno));
        exit(1);
    }
    
    char *buf = (char *)malloc(len);
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        fprintf(stderr, "sysctl: %s\n", strerror(errno));
        exit(1);
    }
    
    char *lim = buf + len;
    char *next = NULL;
    u_int64_t totalibytes = 0;
    u_int64_t totalobytes = 0;
    u_int64_t totaliPackets = 0;
    u_int64_t totaloPackets = 0;
    
       for (next = buf; next < lim; ){
                      
           struct if_msghdr *ifm = (struct if_msghdr *)next;
           next += ifm->ifm_msglen;
                      
           if (ifm->ifm_type == RTM_IFINFO2) {
                              
               struct if_msghdr2 *if2m = (struct if_msghdr2 *)ifm;
               totalibytes += if2m->ifm_data.ifi_ibytes;
               totalobytes += if2m->ifm_data.ifi_obytes;
               totaliPackets += if2m->ifm_data.ifi_ipackets;
               totaloPackets += if2m->ifm_data.ifi_opackets;

           }
       }
    printf("total received - ibytes %qu\t sent - obytes %qu\n", totalibytes, totalobytes);
    printf("total received - ipackets %qu\t sent - opackets %qu\n", totaliPackets, totaloPackets);
}

@end
