//
//  NSDate+Increment.m
//  MNutrition
//
//  Created by David Quesada on 10/11/13.
//  Copyright (c) 2013 David Quesada. All rights reserved.
//

#import "NSDate+Increment.h"

@implementation NSDate (Increment)

-(NSDate *)dateByAddingDays:(int)days
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.day = days;
    return [calendar dateByAddingComponents:components toDate:self options:0];
}

-(NSDate *)nextDay
{
    return [self dateByAddingDays:1];
}

-(NSDate *)previousDay
{
    return [self dateByAddingDays:-1];
}

@end
