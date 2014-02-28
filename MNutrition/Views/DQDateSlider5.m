//
//  DQDateSlider5.m
//  MNutrition
//
//  Created by David Quesada on 2/28/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "DQDateSlider5.h"

@interface DQDateSlider5 ()
-(void)setupView;
@end

@implementation DQDateSlider5

-(id)init
{
    self = [super init];
    if (self)
    {
        [self setupView];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
        [self setupView];
    return self;
}

-(void)setFrame:(CGRect)frame
{
    frame.size = CGSizeMake(320, 162);
    [super setFrame:frame];
}

-(void)setupView
{
    self.datePickerMode = UIDatePickerModeDate;
    self.frame = self.frame;
}

-(void)setDate:(NSDate *)date
{
    [self setDate:date animated:NO];
}

-(void)setDate:(NSDate *)date animated:(BOOL)animated
{
    if (!date)
        date = [NSDate date];
    [super setDate:date animated:YES];
}

-(BOOL)isLegacyDateSlider
{
    return YES;
}

@end
