//
//  CADAppDelegate.m
//  CADRACSwippeableCell
//
//  Created by Joan Romano on 16/04/14.
//  Copyright (c) 2014 Crows And Dogs. All rights reserved.
//

#import "CADAppDelegate.h"

#import "CADViewController.h"

@implementation CADAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.window.backgroundColor = [UIColor whiteColor];
    
    self.window.rootViewController = [[CADViewController alloc] init];
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
