//
//  DiningHallLocator.h
//  MNutrition
//
//  Created by David Paul Quesada on 3/17/16.
//  Copyright © 2016 David Quesada. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMeals.h"

@interface DiningHallLocator : NSObject

@property(readonly) BOOL canLocate;

-(void)locate:(void (^)(MMDiningHall *hall))callback;

@end
