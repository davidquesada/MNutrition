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
    [string appendFormat:@"Calories: %d\n", object.calories];
    [string appendFormat:@" - Calories from Fat: %d\n", object.caloriesFromFat];
    [string appendFormat:@"Total Fat: %d g\n", object.fat];
    [string appendFormat:@" - Saturated Fat: %d g\n", object.saturatedFat];
    [string appendFormat:@" - Trans Fat: %d g\n", object.transFat];
    [string appendFormat:@"Cholesterol: %d mg\n", object.cholesterol];
    [string appendFormat:@"Sodium: %d mg\n", object.sodium];
    [string appendFormat:@"Total Carbohydrates: %d g\n", object.carbohydrates];
    [string appendFormat:@" - Dietary Fiber: %d g\n", object.fiber];
    [string appendFormat:@" - Sugar: %d \n", object.sugar];
    [string appendFormat:@"Protein: %d g", object.protein];
    
    return string;
}
