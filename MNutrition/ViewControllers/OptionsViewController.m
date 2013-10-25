//
//  OptionsViewController.m
//  MNutrition
//
//  Created by David Quesada on 10/10/13.
//  Copyright (c) 2013 David Quesada. All rights reserved.
//

#import "OptionsViewController.h"
#import "AppDelegate.h"
#import "MMeals.h"
#import "SVProgressHUD.h"

@interface OptionsViewController ()<UITableViewDataSource, UITableViewDelegate>

@property NSArray *allDiningHalls;

@property IBOutlet UISegmentedControl *mealTypeSegmentedControl;
@property IBOutlet UIDatePicker *datePicker;

@end

@implementation OptionsViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.allDiningHalls = [MMDiningHall allDiningHalls];
    
    if (!self.selectedDiningHall)
        self.navigationItem.leftBarButtonItem.enabled = NO;
    
    if (self.selectedDate)
        self.datePicker.date = self.selectedDate;
    
    if (self.mealType == MMMealTypeBreakfast)
        self.mealTypeSegmentedControl.selectedSegmentIndex = 0;
    else if (self.mealType == MMMealTypeLunch)
        self.mealTypeSegmentedControl.selectedSegmentIndex = 1;
    else if (self.mealType == MMMealTypeDinner)
        self.mealTypeSegmentedControl.selectedSegmentIndex = 2;
}

-(void)downloadMenu:(void (^)())completion
{
    static MMMealType mealTypes[3] = { MMMealTypeBreakfast, MMMealTypeLunch, MMMealTypeDinner };
    
    MMMealType mealType = mealTypes[self.mealTypeSegmentedControl.selectedSegmentIndex];
    NSDate *date = self.datePicker.date;
    
    self.selectedDate = date;
    self.mealType = mealType;
    
    [self.selectedDiningHall fetchMenuInformationForDate:date completion:^{
        MMMenu *menu = [self.selectedDiningHall menuInformationForDate:date];
        NSArray *courses = [menu coursesForMeal:mealType];
        [AppDelegate mainInstance].coursesForActiveMeal = courses;
        
        completion();
    }];
}

-(IBAction)dismiss:(id)sender
{
    self.navigationItem.leftBarButtonItem.enabled = NO;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    
    [self downloadMenu:^{
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        if ([self.delegate respondsToSelector:@selector(optionsViewControllerWillDismiss:)])
            [self.delegate optionsViewControllerWillDismiss:self];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

#pragma mark - UITableViewDataSource / Delegate Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.allDiningHalls.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"diningHallCell"];
    MMDiningHall *hall = [self.allDiningHalls objectAtIndex:indexPath.row];
    cell.textLabel.text = hall.name;
    
    if (hall == self.selectedDiningHall)
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectedDiningHall = [self.allDiningHalls objectAtIndex:indexPath.row];
    
    [tableView reloadRowsAtIndexPaths:[tableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationFade];
    
    self.navigationItem.leftBarButtonItem.enabled = YES;
}

@end
