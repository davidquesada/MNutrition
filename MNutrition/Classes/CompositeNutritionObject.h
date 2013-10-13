//
//  CompositeNutritionObject.h
//  MNutrition
//
//  Created by David Quesada on 10/12/13.
//  Copyright (c) 2013 David Quesada. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DQNutritionObject.h"

@class MMMenuItem;

@interface CompositeNutritionObject : NSObject<DQNutritionObject>

-(void)addItem:(MMMenuItem *)item;
-(void)removeItem:(MMMenuItem *)item;
-(void)removeAllObjects;
-(int)itemCount;
-(NSUInteger)countOfItem:(MMMenuItem *)item;

@end
