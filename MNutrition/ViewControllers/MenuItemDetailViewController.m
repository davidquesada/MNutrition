//
//  MenuItemDetailViewController.m
//  MNutrition
//
//  Created by David Quesada on 10/11/13.
//  Copyright (c) 2013 David Quesada. All rights reserved.
//

#import "MenuItemDetailViewController.h"
#import "MMeals.h"
#import "DQNutritionView.h"

@interface MenuItemDetailViewController ()
@property IBOutlet DQNutritionView *nutritionView;
@end

@implementation MenuItemDetailViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = self.menuItem.name;
    
    self.nutritionView.nutritionInfo = self.menuItem;
}

@end
