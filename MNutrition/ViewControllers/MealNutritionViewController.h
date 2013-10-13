//
//  MealNutritionViewController.h
//  MNutrition
//
//  Created by David Quesada on 10/11/13.
//  Copyright (c) 2013 David Quesada. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DiningMenuViewController;
@class DQNutritionView;

@interface MealNutritionViewController : UIViewController

@property IBOutlet UINavigationBar *navigationBar;
@property IBOutlet DQNutritionView *nutritionView;
@property(weak) DiningMenuViewController *diningMenu;

@end
