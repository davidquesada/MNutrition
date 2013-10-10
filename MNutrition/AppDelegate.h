//
//  AppDelegate.h
//  MNutrition
//
//  Created by David Quesada on 10/9/13.
//  Copyright (c) 2013 David Quesada. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

+(instancetype)mainInstance;

@end

// Global app-wide variables

//@class MMDiningHall;
@class MMMenu;

@interface AppDelegate ()

//@property MMMenu *activeMenu;

@property NSArray *coursesForActiveMeal;

@end
