//
//  MainSplitViewController.m
//  MNutrition
//
//  Created by David Quesada on 3/30/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "MainSplitViewController.h"

@interface MainSplitViewController ()<UISplitViewControllerDelegate>

@end

@implementation MainSplitViewController

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
        self.delegate = self;
    return self;
}

-(BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
    return NO;
}

@end
