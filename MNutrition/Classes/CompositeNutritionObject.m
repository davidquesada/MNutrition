//
//  CompositeNutritionObject.m
//  MNutrition
//
//  Created by David Quesada on 10/12/13.
//  Copyright (c) 2013 David Quesada. All rights reserved.
//

#import "CompositeNutritionObject.h"
#import "MMMenuItem.h"

@interface CompositeNutritionObject ()

@property NSCountedSet *items;

@property (readwrite) int calories;
@property (readwrite) int caloriesFromFat;

@property (readwrite) int fat;
@property (readwrite) int saturatedFat;
@property (readwrite) int transFat;

@property (readwrite) int cholesterol;
@property (readwrite) int sodium;

@property (readwrite) int carbohydrates;
@property (readwrite) int fiber;
@property (readwrite) int sugar;
@property (readwrite) int protein;

@property (readwrite) NSMutableDictionary *percentages;

@end

@implementation CompositeNutritionObject

- (id)init
{
    self = [super init];
    if (self) {
        self.items = [[NSCountedSet alloc] init];
        self.percentages = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(void)addItem:(MMMenuItem *)item
{
    [self.items addObject:item];
    
    self.calories += item.calories;
    self.caloriesFromFat += item.caloriesFromFat;
    self.fat += item.fat;
    self.saturatedFat += item.saturatedFat;
    self.transFat += item.transFat;
    self.cholesterol += item.cholesterol;
    self.sodium += item.sodium;
    self.carbohydrates += item.carbohydrates;
    self.fiber += item.fiber;
    self.sugar += item.sugar;
    self.protein += item.protein;
    
    [item.percentages enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        int currentValue = [self.percentages[key] intValue];
        int newValue = currentValue + [obj intValue];
        self.percentages[key] = @(newValue);
    }];
}

-(void)removeItem:(MMMenuItem *)item
{
    int count = [self.items countForObject:item];

    if (!count)
        return;
    
    while ([self.items countForObject:item])
        [self.items removeObject:item];
    
    self.calories -= item.calories * count;
    self.caloriesFromFat -= item.caloriesFromFat * count;
    self.fat -= item.fat * count;
    self.saturatedFat -= item.saturatedFat * count;
    self.transFat -= item.transFat * count;
    self.cholesterol -= item.cholesterol * count;
    self.sodium -= item.sodium * count;
    self.carbohydrates -= item.carbohydrates * count;
    self.fiber -= item.fiber * count;
    self.sugar -= item.sugar * count;
    self.protein -= item.protein * count;
    
    [item.percentages enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        int currentValue = [self.percentages[key] intValue];
        int newValue = currentValue - ([obj intValue] * count);
        self.percentages[key] = @(newValue);
    }];
}

-(void)removeAllObjects
{
    [self.items removeAllObjects];
    
    self.calories = 0;
    self.caloriesFromFat = 0;
    self.fat = 0;
    self.saturatedFat = 0;
    self.transFat = 0;
    self.cholesterol = 0;
    self.sodium = 0;
    self.carbohydrates = 0;
    self.fiber = 0;
    self.sugar = 0;
    self.protein = 0;
    
    [self.percentages removeAllObjects];
}

-(int)itemCount
{
    return [self.items count];
}

-(NSUInteger)countOfItem:(MMMenuItem *)item
{
    return [self.items countForObject:item];
}

#pragma mark - DQNutritionObject Properties

-(int)portionSize
{
    return 0;
}

-(NSString *)servingSize
{
    return @"1 Meal";
}

@end
