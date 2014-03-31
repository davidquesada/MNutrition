//
//  DQDateSlider.h
//  MNutrition
//
//  Created by David Quesada on 1/31/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DQDateSlider : UIControl

@property NSDate *date;
-(void)setDate:(NSDate *)date animated:(BOOL)animated;

-(BOOL)isLegacyDateSlider;

@end
