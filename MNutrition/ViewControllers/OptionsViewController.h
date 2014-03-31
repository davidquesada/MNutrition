//
//  OptionsViewController.h
//  MNutrition
//
//  Created by David Quesada on 10/10/13.
//  Copyright (c) 2013 David Quesada. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMeals.h"

@class OptionsViewController;

@protocol OptionsViewControllerDelegate <NSObject>
@optional
-(void)optionsViewControllerDidChooseOptions:(OptionsViewController *)controller;
@end

@interface OptionsViewController : UIViewController

@property MMDiningHall *selectedDiningHall;
@property MMMealType mealType;
@property NSDate *selectedDate;

@property id<OptionsViewControllerDelegate> delegate;

-(void)writeOptionsToUI;

@end
