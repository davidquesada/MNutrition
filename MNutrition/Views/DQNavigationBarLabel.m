//
//  DQNavigationBarLabel.m
//  MNutrition
//
//  Created by David Quesada on 10/11/13.
//  Copyright (c) 2013 David Quesada. All rights reserved.
//

#import "DQNavigationBarLabel.h"

@interface DQNavigationBarLabel ()
@property UILabel *titleLabel;
@property UILabel *subtitleLabel;
@end

@implementation DQNavigationBarLabel

-(void)setup
{
    self.titleLabel = [[UILabel alloc] initWithFrame:self.bounds];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:17.0f];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.opaque = NO;
    [self addSubview:self.titleLabel];
    
    CGRect rect = self.bounds;
    rect.origin.y += 10;
    
    self.subtitleLabel = [[UILabel alloc] initWithFrame:rect];
    self.subtitleLabel.font = [UIFont systemFontOfSize:12.0f];
    self.subtitleLabel.textAlignment = NSTextAlignmentCenter;
    self.subtitleLabel.backgroundColor = [UIColor clearColor];
    self.subtitleLabel.opaque = NO;
    [self addSubview:self.subtitleLabel];
    
    if ([[UIDevice currentDevice].systemVersion integerValue] < 7)
        self.titleLabel.textColor = self.subtitleLabel.textColor = [UIColor whiteColor];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (id)init
{
    self = [self initWithFrame:CGRectMake(0, 0, 190, 44)];
    return self;
}

-(NSString *)text
{
    return self.titleLabel.text;
}

-(void)setText:(NSString *)text
{
    self.titleLabel.text = text;
    [self positionLabels];
}

-(NSString *)subtitle
{
    return self.subtitleLabel.text;
}

-(void)setSubtitle:(NSString *)subtitle
{
    self.subtitleLabel.text = subtitle;
    [self positionLabels];
}

-(void)positionLabels
{
    if (!self.subtitleLabel.text.length)
    {
        self.titleLabel.frame = self.bounds;
        return;
    }
    
    CGRect rect = self.bounds;
    rect.origin.y -= 7;
    self.titleLabel.frame = rect;
}

@end
