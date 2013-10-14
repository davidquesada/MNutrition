//
//  DQNutritionObject.h
//  MNutrition
//
//  Created by David Quesada on 10/12/13.
//  Copyright (c) 2013 David Quesada. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DQNutritionObject <NSObject>
@required

@property (readonly) int calories;
@property (readonly) int caloriesFromFat;

@property (readonly) int fat;
@property (readonly) int saturatedFat;
@property (readonly) int transFat;

@property (readonly) int cholesterol;
@property (readonly) int sodium;

@property (readonly) int carbohydrates;
@property (readonly) int fiber;
@property (readonly) int sugar;
@property (readonly) int protein;

@property (readonly) int portionSize;
@property (readonly) NSString *servingSize;

@end

NSString *DQNutritionObjectLongDescription(id<DQNutritionObject> object);