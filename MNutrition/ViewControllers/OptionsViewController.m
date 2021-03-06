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
{
    BOOL _useLegacyHighlightColor;
}

@property NSArray *allDiningHalls;

@property IBOutlet UISegmentedControl *mealTypeSegmentedControl;
@property IBOutlet DQDateSlider *datePicker;
@property(weak) IBOutlet UITableView *tableView;
@property(weak) IBOutlet UIView *bottomTrayView;
@property(weak) IBOutlet UIToolbar *toolbar;
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
    
    if (self.splitViewController)
    {
        // WOO!
        DiningMenuViewController *menu = [[[[[self splitViewController] viewControllers] lastObject] viewControllers] lastObject];
        self.delegate = (id)menu;
        menu.optionsViewController = self;
    }
    
    [self continueToMenuIfPossible];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        // Make some adjustments so that on a 4-inch screen, 8 items fit perfectly
        // and the cell dividers don't interfere with the hairline border of the bottom view.
        CGFloat f = 0;
        if ((f = [UIScreen mainScreen].scale) > 2.1)
            self.tableView.rowHeight = 50; // No half-point things on i6+. It looks weird.
        else if ([UIScreen mainScreen].scale > 1.9)
        {
            self.tableView.rowHeight = 49.5;
            self.tableView.contentInset = UIEdgeInsetsMake(1, 0, -1, 0);
        }
    }
    else //iPad
    {
        self.tableView.rowHeight = 52;
        self.tableView.contentInset = UIEdgeInsetsMake(-1.5, 0, 0, 0);
        self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:(CGRect){1,1,1,1}];
    }
    
    // Give the legacy date slider (i.e. UIDatePicker) some more room. It wants to be 216 pt high.
    if ([_datePicker isLegacyDateSlider])
    {
        CGFloat diff = 162 - (self.bottomTrayView.frame.size.height - self.datePicker.frame.origin.y);
        
        CGRect f = self.tableView.frame;
        f.size.height -= diff;
        self.tableView.frame = f;
        
        f = self.bottomTrayView.frame;
        f.size.height += diff;
        f.origin.y -= diff;
        self.bottomTrayView.frame = f;
    }
    
    // The UIToolbar class puts the the segmented control too close to the top of the
    // toolbar for my taste, so shift the toolbar down.
    if ([AppDelegate isIOS7])
        self.toolbar.frame = CGRectOffset(self.toolbar.bounds, 0, 4);
    
    _useLegacyHighlightColor = [[[UIDevice currentDevice] systemVersion] intValue] < 7;
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
    [self writeOptionsToUI];
    [self showMenu:NO];
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

-(void)showMenu:(BOOL)animated
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        if (animated)
            [self performSegueWithIdentifier:@"showMenu" sender:nil];
        else
        {
            UIViewController *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"diningMenu"];
            UIStoryboardSegue *seg = [UIStoryboardSegue segueWithIdentifier:@"showMenu" source:self destination:dest performHandler:^{
                [self.navigationController pushViewController:dest animated:NO];
            }];
            [self prepareForSegue:seg sender:self];
            [seg perform];
        }
    }
    else
    {
        if (!self.selectedDiningHall)
            return;
        
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        [self downloadMenu:^{
            [SVProgressHUD dismiss];
            [self reportDidChooseOptionsToPotentialListener:self.delegate];
        }];
    }
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
    [self.tableView reloadData];
    
    NSUInteger idx = [_allDiningHalls indexOfObject:_selectedDiningHall];
    if (idx != NSNotFound)
    {
        NSIndexPath *path = [NSIndexPath indexPathForRow:idx inSection:0];
        [_tableView selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

/* Informs the given object that the receiver has chosen menu options. The listener argmuent is not required to implement any protocols, and if it doesn't, this method will send no other messages to the listener..
 */
-(void)reportDidChooseOptionsToPotentialListener:(id)listener
{
    [self writeUIToOptions];
    if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) && !self.selectedDiningHall)
        return;
    if (![listener respondsToSelector:@selector(optionsViewControllerDidChooseOptions:)])
        return;
    [listener optionsViewControllerDidChooseOptions:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id destination = segue.destinationViewController;
    
    if ([destination isKindOfClass:[UINavigationController class]])
        destination = [[destination viewControllers] firstObject];
    
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

-(IBAction)mealTypeWasChanged:(id)sender
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        [self reportDidChooseOptionsToPotentialListener:[self delegate]];
}

-(IBAction)dateWasChanged:(id)sender
{
    self.selectedDate = self.datePicker.date;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        [self showMenu:YES];
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
    
    if (_useLegacyHighlightColor)
        cell.textLabel.highlightedTextColor = [UIColor whiteColor];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedDiningHall = [self.allDiningHalls objectAtIndex:indexPath.row];
    
    [self showMenu:YES];
}

@end
