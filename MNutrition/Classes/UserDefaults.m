//
//  UserDefaults.m
//  MNutrition
//
//  Created by David Quesada on 1/26/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "UserDefaults.h"

@implementation UserDefaults

+(UserDefaults *)defaultManager
{
    static UserDefaults *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[UserDefaults alloc] init];
    });
    return manager;
}

-(BOOL)writeToUserDefaults
{
    id payload = @{
                   @"date" : self.date,
                   @"mealType" : @(self.mealType),
                   @"diningHallType" : @(self.diningHall.type),
                   };
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:payload forKey:@"defaultMenuInfo"];
    return [defaults synchronize];
}

-(BOOL)readFromUserDefaults
{
    NSDictionary *payload = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"defaultMenuInfo"];
    
    if (!payload)
        return NO;
    
    id diningHallType = payload[@"diningHallType"];
    if (diningHallType == nil || diningHallType == [NSNull null])
        return NO;
    
//    self.date = payload[@"date"];
//    self.mealType = (MMMealType)[payload[@"mealType"] intValue];
    
    self.date = [NSDate date];
    self.mealType = MMMealTypeFromTime(self.date);
    
    self.diningHall = [MMDiningHall diningHallOfType:(MMDiningHallType)[diningHallType intValue]];
    
    if (!self.date || !self.diningHall)
        return NO;
    return YES;
}

@end
