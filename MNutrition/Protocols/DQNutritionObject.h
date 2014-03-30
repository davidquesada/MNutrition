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

@property (readonly) NSInteger calories;
@property (readonly) NSInteger caloriesFromFat;

@property (readonly) NSInteger fat;
@property (readonly) NSInteger saturatedFat;
@property (readonly) NSInteger transFat;

@property (readonly) NSInteger cholesterol;
@property (readonly) NSInteger sodium;

@property (readonly) NSInteger carbohydrates;
@property (readonly) NSInteger fiber;
@property (readonly) NSInteger sugar;
@property (readonly) NSInteger protein;

@property (readonly) NSInteger portionSize;
@property (readonly) NSString *servingSize;

@property (readonly) NSDictionary *percentages;

@end

NSString *DQNutritionObjectLongDescription(id<DQNutritionObject> object);