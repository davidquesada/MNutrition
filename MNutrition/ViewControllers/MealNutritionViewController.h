//
//  MealNutritionViewController.h
//  MNutrition
//
//  Created by David Quesada on 10/11/13.
//  Copyright (c) 2013 David Quesada. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DiningMenuViewController;

@interface MealNutritionViewController : UIViewController

@property IBOutlet UINavigationBar *navigationBar;
@property(weak) DiningMenuViewController *diningMenu;

@end
