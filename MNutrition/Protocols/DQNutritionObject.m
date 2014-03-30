//
//  DQNutritionObject.m
//  MNutrition
//
//  Created by David Quesada on 10/13/13.
//  Copyright (c) 2013 David Quesada. All rights reserved.
//

#include "DQNutritionObject.h"

NSString *DQNutritionObjectLongDescription(id<DQNutritionObject> object)
{
    NSMutableString *string = [[NSMutableString alloc] init];
    
    [string appendFormat:@"Serving Size: %@\n", object.servingSize];
    [string appendFormat:@"\n"];
    [string appendFormat:@"Calories: %d\n", (int)object.calories];
    [string appendFormat:@" - Calories from Fat: %d\n", (int)object.caloriesFromFat];
    [string appendFormat:@"Total Fat: %d g\n", (int)object.fat];
    [string appendFormat:@" - Saturated Fat: %d g\n", (int)object.saturatedFat];
    [string appendFormat:@" - Trans Fat: %d g\n", (int)object.transFat];
    [string appendFormat:@"Cholesterol: %d mg\n", (int)object.cholesterol];
    [string appendFormat:@"Sodium: %d mg\n", (int)object.sodium];
    [string appendFormat:@"Total Carbohydrates: %d g\n", (int)object.carbohydrates];
    [string appendFormat:@" - Dietary Fiber: %d g\n", (int)object.fiber];
    [string appendFormat:@" - Sugar: %d \n", (int)object.sugar];
    [string appendFormat:@"Protein: %d g", (int)object.protein];
    
    return string;
}
