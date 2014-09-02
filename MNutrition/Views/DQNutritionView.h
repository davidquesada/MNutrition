//
//  DQNutritionView.h
//  MNutrition
//
//  Created by David Quesada on 10/11/13.
//  Copyright (c) 2013 David Quesada. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DQNutritionObject.h"

@interface DQNutritionView : UIView

@property(nonatomic) id<DQNutritionObject> nutritionInfo;

@property(nonatomic) UIColor *separatorColor;
@property(nonatomic) BOOL scrollEnabled;

@end
