//
//  AppDelegate.m
//  MNutrition
//
//  Created by David Quesada on 10/9/13.
//  Copyright (c) 2013 David Quesada. All rights reserved.
//

#import "AppDelegate.h"
#import "SVProgressHUD.h"

AppDelegate *mainInstance;
BOOL ios7;
BOOL ios6;
BOOL ios8;

@implementation AppDelegate

+(instancetype)mainInstance
{
    return mainInstance;
}

+(BOOL)isIOS8
{
    return ios8;
}

+(BOOL)isIOS7
{
    return ios7;
}

+(BOOL)isIOS6
{
    return ios6;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    mainInstance = self;
    
    ios8 = ([[UIDevice currentDevice].systemVersion integerValue] >= 8);
    ios7 = ([[UIDevice currentDevice].systemVersion integerValue] >= 7);
    ios6 = ([[UIDevice currentDevice].systemVersion integerValue] >= 6);
    
    if (!ios7)
    {
        [[UINavigationBar appearance] setTintColor:[UIColor blueColor]];
    }
    
    if (ios6 && !ios7)
    {
//        [[UIToolbar appearance] setTintColor:[UIColor yellowColor]];
        UIImage *img = [[UIImage alloc] init];
        [[UIToolbar appearance] setBackgroundImage:img forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
        [[UIToolbar appearance] setShadowImage:img forToolbarPosition:UIBarPositionAny];
        [[UISegmentedControl appearance] setTintColor:[UIColor darkGrayColor]];
    }
    
    if (ios7)
    {
        UIImage *img = [[UIImage alloc] init];
        [[UIToolbar appearance] setBackgroundImage:img forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
        [[UIToolbar appearance] setShadowImage:img forToolbarPosition:UIBarPositionAny];
    }
    
    [self updateProgressHUDOffset:application.statusBarOrientation];
    
    return YES;
}

-(void)updateProgressHUDOffset:(UIInterfaceOrientation)orientation
{
    // Center the progress HUD on the detail pane of the splitviewcontroller.
    // (Don't do this on iPhone.)
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
        return;
    
    CGFloat x = 160, y = 0;
    UIOffset off = UIOffsetZero;
    
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
            off = UIOffsetMake(x, y);
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            off = UIOffsetMake(-x, -y);
            break;
        case UIInterfaceOrientationLandscapeLeft:
            off = UIOffsetMake(y, -x);
            break;
        case UIInterfaceOrientationLandscapeRight:
            off = UIOffsetMake(-y, x);
            break;
        default:
            break;
    }
    
    [SVProgressHUD setOffsetFromCenter:off];
}

-(void)application:(UIApplication *)application willChangeStatusBarOrientation:(UIInterfaceOrientation)newStatusBarOrientation duration:(NSTimeInterval)duration
{
    [self updateProgressHUDOffset:newStatusBarOrientation];
}

@end
