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
#import "DiningMenuViewController.h"
#import "UserDefaults.h"
#import "DQDateSlider.h"

@interface OptionsViewController ()<UITableViewDataSource, UITableViewDelegate>

@property NSArray *allDiningHalls;

@property IBOutlet UISegmentedControl *mealTypeSegmentedControl;
@property IBOutlet DQDateSlider *datePicker;
@property MMMealType shownMealType;
@property BOOL hasLaunched;

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
    
    [self continueToMenuIfPossible];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self writeOptionsToUI];
}

-(void)continueToMenuIfPossible
{
    // Only do this once.
    if (self.hasLaunched)
        return;
    self.hasLaunched = YES;
    
    UserDefaults *manager = [UserDefaults defaultManager];
    if (![manager readFromUserDefaults])
        return;
    self.selectedDate = manager.date;
    self.selectedDiningHall = manager.diningHall;
    self.mealType = manager.mealType;
    [self showMenu];
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
        
        if ([self.delegate respondsToSelector:@selector(optionsViewControllerDidChooseOptions:)])
            [self.delegate optionsViewControllerDidChooseOptions:self];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

-(void)showMenu
{
    [self performSegueWithIdentifier:@"showMenu" sender:nil];
}

-(void)writeUIToOptions
{
    self.selectedDate = self.datePicker.date;
    if (!self.selectedDate)
        self.selectedDate = [NSDate date];
    self.mealType = self.shownMealType;
    
    // It's not necessary to assign self.selectedDiningHall to itself.
}

-(void)writeOptionsToUI
{
    if (!self.selectedDate)
        self.selectedDate = [NSDate date];
    self.datePicker.date = self.selectedDate;
    self.shownMealType = self.mealType;
}

/* Informs the given object that the receiver has chosen menu options. The listener argmuent is not required to implement any protocols, and if it doesn't, this method will send no other messages to the listener..
 */
-(void)reportDidChooseOptionsToPotentialListener:(id)listener
{
    [self writeUIToOptions];
    if (![listener respondsToSelector:@selector(optionsViewControllerDidChooseOptions:)])
        return;
    [listener optionsViewControllerDidChooseOptions:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id destination = segue.destinationViewController;
    [self reportDidChooseOptionsToPotentialListener:destination];
    
    if ([destination isKindOfClass:[DiningMenuViewController class]])
        [destination setOptionsViewController:self];
}

-(MMMealType)shownMealType
{
    switch (self.mealTypeSegmentedControl.selectedSegmentIndex)
    {
        case 0: return MMMealTypeBreakfast;
        case 1: return MMMealTypeLunch;
        case 2: return MMMealTypeDinner;
        default: return MMMealTypeNone;
    }
}

-(void)setShownMealType:(MMMealType)shownMealType
{
    int val = 0;
    switch (shownMealType)
    {
        case MMMealTypeBreakfast: val = 0; break;
        case MMMealTypeLunch: val = 1; break;
        case MMMealTypeDinner: val = 2; break;
        default: break;
    }
    self.mealTypeSegmentedControl.selectedSegmentIndex = val;
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
        cell.textLabel.textColor = [UIColor blueColor];
    else
        cell.textLabel.textColor = [UIColor blackColor];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectedDiningHall = [self.allDiningHalls objectAtIndex:indexPath.row];
    
    [tableView reloadRowsAtIndexPaths:[tableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationFade];
    
    [self showMenu];
}

@end
