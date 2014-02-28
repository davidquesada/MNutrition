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
    [self.diningMenu addPanGestureToView:self.navigationBar];
    
    // Sharing is not included in pre-ios6 SDK.
    if (![AppDelegate isIOS6])
    {
        UINavigationItem *item = self.navigationBar.items.lastObject;
        item.rightBarButtonItem = nil;
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
