//
//  AppDelegate.m
//  DNSTest
//
//  Created by lujb on 15/6/18.
//  Copyright (c) 2015年 lujb. All rights reserved.
//

#import "AppDelegate.h"
#import <resolv.h>
#include <arpa/inet.h>


#include <netdb.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <ifaddrs.h>
#include <net/if.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
    
    //方法 1
    unsigned char auResult[512];
    int nBytesRead = 0;
    
    nBytesRead = res_query("www.baidu.com", ns_c_in, ns_t_a, auResult, sizeof(auResult));
    
    ns_msg handle;
    ns_initparse(auResult, nBytesRead, &handle);
    
    NSMutableArray *ipList = nil;
    int msg_count = ns_msg_count(handle, ns_s_an);
    if (msg_count > 0) {
        ipList = [[NSMutableArray alloc] initWithCapacity:msg_count];
        for(int rrnum = 0; rrnum < msg_count; rrnum++) {
            ns_rr rr;
            if(ns_parserr(&handle, ns_s_an, rrnum, &rr) == 0) {
                char ip1[16];
                strcpy(ip1, inet_ntoa(*(struct in_addr *)ns_rr_rdata(rr)));
                NSString *ipString = [[NSString alloc] initWithCString:ip1 encoding:NSASCIIStringEncoding];
                if (![ipString isEqualToString:@""]) {
                    
                    //将提取到的IP地址放到数组中
                    [ipList addObject:ipString];
                }
            }
        }
    }
    
    //方法 2
    
    struct hostent *host = gethostbyname("www.google.com.hk");
    
    struct in_addr **list = (struct in_addr **)host->h_addr_list;
    NSString *ip= [NSString stringWithCString:inet_ntoa(*list[0]) encoding:NSUTF8StringEncoding];
    NSLog(@"ip address is : %@",ip);
    
    //方法 3
    Boolean result,bResolved;
    CFHostRef hostRef;
    CFArrayRef addresses = NULL;

    CFStringRef hostNameRef = CFStringCreateWithCString(kCFAllocatorDefault, "www.google.com.hk", kCFStringEncodingASCII);
    
    hostRef = CFHostCreateWithName(kCFAllocatorDefault, hostNameRef);
    if (hostRef) {
        result = CFHostStartInfoResolution(hostRef, kCFHostAddresses, NULL);
        if (result == TRUE) {
            addresses = CFHostGetAddressing(hostRef, &result);
        }
    }
    bResolved = result == TRUE ? true : false;
    
    if(bResolved)
    {
        struct sockaddr_in* remoteAddr;
        for(int i = 0; i < CFArrayGetCount(addresses); i++)
        {
            CFDataRef saData = (CFDataRef)CFArrayGetValueAtIndex(addresses, i);
            remoteAddr = (struct sockaddr_in*)CFDataGetBytePtr(saData);
            
            if(remoteAddr != NULL)
            {
                //获取IP地址
                char ip[16];
                strcpy(ip, inet_ntoa(remoteAddr->sin_addr));
            }
        }
    }
    CFRelease(hostNameRef);
    CFRelease(hostRef);
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
