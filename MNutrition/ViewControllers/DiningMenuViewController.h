//
//  DiningMenuViewController.h
//  MNutrition
//
//  Created by David Quesada on 10/9/13.
//  Copyright (c) 2013 David Quesada. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMeals.h"

@class CompositeNutritionObject;
@class OptionsViewController;

@interface DiningMenuViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property MMDiningHall *selectedDiningHall;
@property MMMealType mealType;
@property NSDate *selectedDate;

@property (readonly) CompositeNutritionObject *nutritionObject;
@property (weak) OptionsViewController *optionsViewController;

-(void)setNutritionVisible:(BOOL)visible;
-(void)addPanGestureToView:(UIView *)view;

@end
