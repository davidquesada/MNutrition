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

@interface OptionsViewController ()<UITableViewDataSource, UITableViewDelegate>

@property NSArray *allDiningHalls;

@property (weak) MMDiningHall *selectedDiningHall;
@property IBOutlet UISegmentedControl *mealTypeSegmentedControl;
@property IBOutlet UIDatePicker *datePicker;

@end

@implementation OptionsViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.allDiningHalls = [MMDiningHall allDiningHalls];
}

-(void)downloadMenu:(void (^)())completion
{
    static MMMealType mealTypes[3] = { MMMealTypeBreakfast, MMMealTypeLunch, MMMealTypeDinner };
    
    MMMealType mealType = mealTypes[self.mealTypeSegmentedControl.selectedSegmentIndex];
    NSDate *date = self.datePicker.date;
    
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
    [self downloadMenu:^{
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
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
}

@end
