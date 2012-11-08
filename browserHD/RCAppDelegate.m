//
//  RCAppDelegate.m
//  browserHD
//
//  Created by imac on 12-8-9.
//  Copyright (c) 2012年 2345. All rights reserved.
//

#import "RCAppDelegate.h"

#import "RCViewController.h"
#import "RCRecordData.h"
#import "CoreDataManager+BookMark.h"
#import "MobClick.h"

@implementation RCAppDelegate

//
//-(NSUInteger) asciiLengthOfString: (NSString *) text {
//    NSUInteger asciiLength = 0;
//    
//    for (NSUInteger i = 0; i < text.length; i++) {
//        
//        
//        unichar uc = [text characterAtIndex: i];
//        
//        asciiLength += isascii(uc) ? 1 : 2;
//    }
//    
//    
//    return asciiLength;
//}





- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    NSString* text = @"yi一开你f或者213";
//    NSLog(@"length: %d",[self asciiLengthOfString:text]);
//    NSDate* date = [[NSUserDefaults standardUserDefaults] objectForKey:@"FirstLunchTimerByDay"];
    
    
//    NSString* string = [[NSDate date] description];
//    NSString* newstring = [NSString stringWithFormat:@"%@06:00:00",[string substringToIndex:11]];
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    NSDate* newdate = [dateFormatter dateFromString:newstring];
//    if ([newdate laterDate:[NSDate date]]) {
//        NSLog(@"later");
//    }
    
    
    
    BOOL notFirstLoad = [[NSUserDefaults standardUserDefaults] boolForKey:@"notFirstLoad"];
    if (!notFirstLoad) {
        [RCRecordData prepareDefaultData];
        
        Folder* folder = [[CoreDataManager defaultManager] creatFolderWithTitle:@"我的收藏夹" Unique:[NSNumber numberWithInt:0] Parent:nil];
        if (!folder) {
            NSLog(@"error creat default Folder");
        }else{
            
        }
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:defaultKeyForShortcut];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"notFirstLoad"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.viewController = [[RCViewController alloc] initWithNibName:@"RCViewController" bundle:nil];

    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
//    if (![[NSUserDefaults standardUserDefaults] boolForKey:defaultKeyForRoationLock]) {
        [self.viewController willAnimateRotationToInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation duration:0];
//    }
    
    self.brightnessView = [[UIView alloc] initWithFrame:self.window.bounds];
    self.brightnessView.userInteractionEnabled = NO;
    self.brightnessView.backgroundColor = [UIColor blackColor];

    self.brightnessView.alpha = [[NSUserDefaults standardUserDefaults] floatForKey:defaultKeyForBrightness];

    [self.window addSubview:self.brightnessView];
    
    
    int cacheSizeMemory = 4*1024*1024; // 4MB
    int cacheSizeDisk = 32*1024*1024; // 32MB
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:cacheSizeMemory diskCapacity:cacheSizeDisk diskPath:@"nsurlcache"];
    [NSURLCache setSharedURLCache:sharedCache];
    
    //setup screen shot cache clear
//    5056b26e52701527fe000074
    [MobClick startWithAppkey:@"5056b26e52701527fe000074" reportPolicy:REALTIME channelId:nil];
    [MobClick checkUpdate];

    
    [[RCRecordData class] performSelectorInBackground:@selector(clearImageCaches) withObject:nil];
    
    

    
    return YES;
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return (UIInterfaceOrientationMaskAll);
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    NSLog(@"resign active");
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"background");
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSLog(@"applicationWillEnterForeground");

    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSLog(@"applicationDidBecomeActive");

    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    NSLog(@"terminate");
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
