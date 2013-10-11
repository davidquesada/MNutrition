//
//  MealNutritionViewController.m
//  MNutrition
//
//  Created by David Quesada on 10/11/13.
//  Copyright (c) 2013 David Quesada. All rights reserved.
//

#import "MealNutritionViewController.h"
#import "DiningMenuViewController.h"

@interface MealNutritionViewController ()<UINavigationBarDelegate>

@end

@implementation MealNutritionViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self.diningMenu addPanGestureToView:self.navigationBar];
}

-(IBAction)dismiss:(id)sender
{
    [self.diningMenu setNutritionVisible:NO];
}

-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}

@end
