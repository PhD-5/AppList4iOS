//
//  AppListUtils.m
//  AppList
//
//  Created by 於剑波 on 17/6/6.
//  Copyright (c) 2017年 於剑波. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppListUtils.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>

@implementation AppListUtils


+(void) updateAppList_plist{
    NSString * AppListPlistPath = @"/var/mobile/Library/MobileInstallation/LastLaunchServicesMap.plist";
    
    NSMutableDictionary * appListResDict = [[NSMutableDictionary alloc] init];
    
    NSMutableDictionary * installDict = [[NSMutableDictionary alloc] initWithContentsOfFile:AppListPlistPath];
    
    NSMutableDictionary * appListDict = [installDict objectForKey:@"User"];
    
    for(NSString * bundleID in [appListDict allKeys]){
        [appListResDict setObject:[AppListUtils getNameByBundleId:bundleID accordingTo:appListDict] forKey:bundleID];
    }
    
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:appListResDict options:0 error:nil];
    NSString * jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSLog(@"%@",jsonStr);
    
    [AppListUtils sendSocket:jsonStr];
}

+(void) updateAppList{
    
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    
    Class c = NSClassFromString(@"LSApplicationWorkspace");
    id s = [(id)c performSelector:NSSelectorFromString(@"defaultWorkspace")];
    NSArray* arr = [s performSelector:NSSelectorFromString(@"allInstalledApplications")];
    
    for(id item in arr){
        NSString* type = [item performSelector:NSSelectorFromString(@"applicationType")];
        if ([type isEqual:@"User"]){
            NSString* name = [item performSelector:NSSelectorFromString(@"localizedName")];
            NSString* bundle = [item performSelector:NSSelectorFromString(@"applicationIdentifier")];
            [dict setObject:name forKey:bundle];
        }
    }
    
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    NSString * jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [AppListUtils sendSocket:jsonStr];
}

+(void) sendSocket:(NSString *)jsonStr{
    NSString * settingPlist = @"/private/var/mobile/Library/Preferences/com.softsec.iosdefect.socket.plist";
    NSDictionary * preDict = [NSDictionary dictionaryWithContentsOfFile:settingPlist];
    NSString *ip = [preDict valueForKey:@"ServerIP"];
    int port = [[preDict valueForKey:@"ServerPort"] intValue] + 1;
    
    int socketfd = socket(AF_INET, SOCK_STREAM, 0);
    if (socketfd < 0){
        return;
    }
    struct sockaddr_in des_addr;
    des_addr.sin_port = htons(port);
    des_addr.sin_addr.s_addr = inet_addr([ip UTF8String]);
    des_addr.sin_family = AF_INET;
    bzero(&(des_addr.sin_zero), 8);
    
        /* 发送连接请求 */
    if (connect(socketfd, (struct sockaddr *)&des_addr, sizeof(struct sockaddr)) < 0)
    {
        return ;
    }
    /* 发送信息 */
    if (send(socketfd, [jsonStr UTF8String], strlen([jsonStr UTF8String]) + 1, 0) < 0)
    {
        return ;
    }
    close(socketfd);
}

+(NSString *) getNameByBundleId:(NSString *) bundleID accordingTo:(NSMutableDictionary *)appInstalledDict{
    NSString * rootPath = [[appInstalledDict objectForKey:bundleID] valueForKey:@"Path"];
    NSString * infoPath = [NSString stringWithFormat:@"%@/Info.plist",rootPath];
    
    NSMutableDictionary * infoDict = [[NSMutableDictionary alloc] initWithContentsOfFile:infoPath];
    NSString * bundleName = [infoDict valueForKey:@"CFBundleName"];
    
    return bundleName;
}

@end