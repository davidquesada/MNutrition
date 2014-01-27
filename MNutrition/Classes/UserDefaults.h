//
//  UserDefaults.h
//  MNutrition
//
//  Created by David Quesada on 1/26/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMeals.h"

@interface UserDefaults : NSObject

+(UserDefaults *)defaultManager;

@property MMDiningHall *diningHall;
@property MMMealType mealType;
@property NSDate *date;

-(BOOL)readFromUserDefaults;
-(BOOL)writeToUserDefaults;

@end
