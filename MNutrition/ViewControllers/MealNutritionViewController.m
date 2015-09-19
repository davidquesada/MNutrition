//
//  MealNutritionViewController.m
//  MNutrition
//
//  Created by David Quesada on 10/11/13.
//  Copyright (c) 2013 David Quesada. All rights reserved.
//

#import "MealNutritionViewController.h"
#import "DiningMenuViewController.h"
#import "UIView+SafeScreenshot.h"
#import "DQNutritionObject.h"
#import "CompositeNutritionObject.h"
#import "AppDelegate.h"

@interface MealNutritionViewController ()<UINavigationBarDelegate>
@property (weak) IBOutlet UIView *contentsView;
@end

@implementation MealNutritionViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
        [self.diningMenu addPanGestureToView:self.navigationBar];
    
    // Sharing is not included in pre-ios6 SDK.
    if (![AppDelegate isIOS6])
    {
        UINavigationItem *item = self.navigationBar.items.lastObject;
        item.rightBarButtonItem = nil;
    }
    
    // This is a hack to get the hairline "shadow" for the navigation bar.
    // Since we're being hacky and using the navbar not in a nav controller, it doesn't
    // behave the same and doesn't respond when you set the shadow image.
    if ([AppDelegate isIOS7] && (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone))
    {
        UIView *v = [UIView new];
        v.frame = CGRectMake(0, 43.5, 1024, 0.5);
        v.backgroundColor = [UIColor colorWithRed:.67 green:.67 blue:.67 alpha:1.0];
        
        [self.navigationBar addSubview:v];
    }
}

-(IBAction)dismiss:(id)sender
{
    [self.diningMenu setNutritionVisible:NO];
}

-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}

-(IBAction)share:(id)sender
{
    UIImage *image = [self.contentsView screenshot];
    NSArray *activityItems = @[ DQNutritionObjectLongDescription(self.diningMenu.nutritionObject), image ];
    NSArray *applicationActivities = @[ ];
    
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:applicationActivities];
    
    controller.excludedActivityTypes = @[
                                          UIActivityTypeAssignToContact,
                                          UIActivityTypePostToTwitter,
                                          ];
    
    [self presentViewController:controller animated:YES completion:nil];
}

@end
