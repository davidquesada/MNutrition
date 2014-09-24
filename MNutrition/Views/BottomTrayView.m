//
//  BottomTrayView.m
//  MNutrition
//
//  Created by David Quesada on 2/1/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "BottomTrayView.h"

@implementation BottomTrayView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addThings];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self addThings];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self addThings];
    }
    return self;
}

-(void)addThings
{
    UIView *borderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, .5)];
    borderView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    borderView.translatesAutoresizingMaskIntoConstraints = YES;
    borderView.backgroundColor = [UIColor colorWithWhite:.75 alpha:1.0];
    [self addSubview:borderView];
//    self.clipsToBounds = NO;
//    self.layer.shadowColor = [UIColor blackColor].CGColor;
//    self.layer.shadowRadius = 7;
//    self.layer.shadowOpacity = 0.12;
}

@end
