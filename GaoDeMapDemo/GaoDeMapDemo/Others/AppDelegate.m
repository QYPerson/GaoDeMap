//
//  AppDelegate.m
//  GaoDeMapDemo
//
//  Created by zibin on 16/7/22.
//  Copyright © 2016年 zibin. All rights reserved.
//


#import "AppDelegate.h"
#import <MAMapKit/MAMapKit.h>
#import "MainNavVC.h"
#import "SendRangeVC.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //4.配置key
    [MAMapServices sharedServices].apiKey = @"5e6235b9fae719747e2f4001c01bfdea";
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = [[MainNavVC alloc] initWithRootViewController:    [[SendRangeVC alloc ] init]];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
