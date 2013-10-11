//
//  DiningMenuViewController.m
//  MNutrition
//
//  Created by David Quesada on 10/9/13.
//  Copyright (c) 2013 David Quesada. All rights reserved.
//

#import "DiningMenuViewController.h"
#import "OptionsViewController.h"
#import "MenuItemDetailViewController.h"
#import "MealNutritionViewController.h"
#import "AppDelegate.h"
#import "MMeals.h"
#import "DQNavigationBarLabel.h"
#import "NSDate+Increment.h"

@interface DiningMenuViewController ()<OptionsViewControllerDelegate>

@property NSArray *courses;
@property(weak) IBOutlet UITableView *tableView;
@property(weak) IBOutlet UIView *footerView;
@property(weak) IBOutlet UIView *footerContentsView;
@property(weak) IBOutlet UIPanGestureRecognizer *panGesture;

@property CGRect startingFooterRect;
@property MealNutritionViewController *mealNutrition;

@property NSArray *myOriginalLeftItems;
@property CGRect originalFooterFrame;

@property DQNavigationBarLabel *navBarLabel;

@end

@implementation DiningMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.footerView.clipsToBounds = NO;
    self.originalFooterFrame = self.footerView.frame;
    
    self.navBarLabel = [[DQNavigationBarLabel alloc] init];
    self.navigationItem.titleView = self.navBarLabel;
    self.navBarLabel.text = @"MNutrition";
    
    [self restoreMenuSettingsFromUserDefaults];

    // If we were able to restore a dining hall, date, and meal from the user defaults,
    // then let's try to fetch that from the server again.
    if (self.selectedDiningHall)
        [self fetchMenuInformation:^{
            [self reloadMenu];
        }];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.mealNutrition)
        [self performSegueWithIdentifier:@"showMealNutrition" sender:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.selectedDiningHall == nil)
        [self performSegueWithIdentifier:@"showOptions" sender:nil];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showOptions"])
    {
        OptionsViewController *controller = [segue.destinationViewController viewControllers][0];
        controller.delegate = self;
        controller.selectedDate = self.selectedDate;
        controller.selectedDiningHall = self.selectedDiningHall;
        controller.mealType = self.mealType;
    } else if ([segue.identifier isEqualToString:@"showMenuItem"])
    {
        MenuItemDetailViewController *controller = segue.destinationViewController;
        UITableViewCell *cell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        MMMenuItem *item = [self.courses[indexPath.section] items][indexPath.row];
        controller.menuItem = item;
    }
}

-(void)reloadMenu
{
    static NSDateFormatter *formatter;
    
    if (!formatter)
    {
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateStyle = NSDateFormatterMediumStyle;
    }
    
    self.navBarLabel.text = self.selectedDiningHall.name;
    self.navBarLabel.subtitle = [NSString stringWithFormat:@"%@, %@", MMMealTypeToString(self.mealType), [formatter stringFromDate:self.selectedDate]];
    self.courses = [[self.selectedDiningHall menuInformationForDate:self.selectedDate] coursesForMeal:self.mealType];
    [self.tableView reloadData];
    [self.tableView scrollRectToVisible:CGRectMake(0, 44, 1, 1) animated:NO];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    MMCourse *course = [self.courses objectAtIndex:section];
    return course.items.count;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    MMCourse *course = [self.courses objectAtIndex:section];
    return course.name;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.courses.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"menuItemCell"];
    
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"menuItemCell"];
    
    MMMenuItem *item = [self.courses[indexPath.section] items][indexPath.row];
    
    cell.textLabel.text = item.name;
    cell.detailTextLabel.text = @"Baka";
    return cell;
}

-(IBAction)pan:(UIPanGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
        self.startingFooterRect = self.footerView.frame;
    
    CGPoint trans = [sender translationInView:self.footerView];
//    NSLog(@"trans.x: %d, trans.y: %d", (int)trans.x, (int)trans.y);
    trans.x = 0;
    
    CGRect rect = self.startingFooterRect;
    rect = CGRectOffset(rect, 0, trans.y);
    
    float progress = [self setFooterViewFrame:rect];
    
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        float yVelocity = [sender velocityInView:self.view].y;
        
        if (abs(yVelocity) > 1500)
        {
            if (yVelocity < 0)
                [self setNutritionVisible:YES];
            else
                [self setNutritionVisible:NO];
        }
        else
        {
            if (progress < 0.5f)
                [self setNutritionVisible:YES];
            else
                [self setNutritionVisible:NO];
        }
    }
}

-(float)setFooterViewFrame:(CGRect)rect
{
    rect.origin.y = MAX(0, rect.origin.y);
    self.footerView.frame = rect;
    float progress = (rect.origin.y) / (self.footerView.superview.frame.size.height - rect.size.height);
 
    // Move the nutrition view.
    
    CGPoint point = [self.footerView convertPoint:CGPointZero toView:self.footerView.window];
    
    rect = self.mealNutrition.view.frame;
    rect.origin = point;
    self.mealNutrition.view.frame = rect;
    self.mealNutrition.navigationBar.alpha = (1.0f - progress);
    self.footerContentsView.alpha = progress;
    
    return progress;
}

-(void)setNutritionVisible:(BOOL)visible
{
    float time = 0.25f;
    [UIView animateWithDuration:time animations:^{
        if (visible)
        {
            CGRect rect = self.footerView.frame;
            rect.origin = CGPointZero;
            [self setFooterViewFrame:rect];
            self.mealNutrition.view.userInteractionEnabled = YES;
        }
        else
        {
            [self setFooterViewFrame:self.originalFooterFrame];
            self.mealNutrition.view.userInteractionEnabled = NO;
        }
    }];
}

-(void)addPanGestureToView:(UIView *)view
{
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    view.gestureRecognizers = @[ pan ];
}

-(void)cloneTransitionToLeft:(BOOL)toLeft
{
    UIView *temp = [self.tableView snapshotViewAfterScreenUpdates:NO];
    [self.view insertSubview:temp aboveSubview:self.tableView];
    
    [UIView animateWithDuration:0.3f animations:^{
        
        CGRect rect = temp.frame;
        rect.origin.x = (toLeft ? -1.0f : 1.0f) * rect.size.width;
        temp.frame = rect;
        
    } completion:^(BOOL finished) {
        [temp removeFromSuperview];
    }];
}

-(IBAction)showMealNutrition:(id)sender
{
    [self setNutritionVisible:YES];
}

-(void)fetchMenuInformation:(void (^)())completion
{
    id data = [self.selectedDiningHall menuInformationForDate:self.selectedDate];
    
    if (data)
    {
        completion();
        return;
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    [self.selectedDiningHall fetchMenuInformationForDate:self.selectedDate completion:^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        completion();
    }];
}

-(IBAction)moveToNextMeal:(id)sender
{
    if (self.mealType == MMMealTypeDinner)
        self.selectedDate = [self.selectedDate nextDay];
    
    switch (self.mealType)
    {
        case MMMealTypeBreakfast:
            self.mealType = MMMealTypeLunch;
            break;
        case MMMealTypeLunch:
            self.mealType = MMMealTypeDinner;
            break;
        case MMMealTypeDinner:
            self.mealType = MMMealTypeBreakfast;
            break;
        default:
            break;
    }
    
    [self fetchMenuInformation:^{
        [self cloneTransitionToLeft:YES];
        [self reloadMenu];
    }];
}

-(IBAction)moveToPreviousMeal:(id)sender
{
    if (self.mealType == MMMealTypeBreakfast)
        self.selectedDate = [self.selectedDate previousDay];

    switch (self.mealType)
    {
        case MMMealTypeBreakfast:
            self.mealType = MMMealTypeDinner;
            break;
        case MMMealTypeLunch:
            self.mealType = MMMealTypeBreakfast;
            break;
        case MMMealTypeDinner:
            self.mealType = MMMealTypeLunch;
            break;
        default:
            break;
    }
    
    [self fetchMenuInformation:^{
        [self cloneTransitionToLeft:NO];
        [self reloadMenu];
    }];
}

#pragma mark - User Defaults functionality

-(void)writeMenuSettingsToUserDefaults
{
    id payload = @{
                   @"date" : self.selectedDate,
                   @"mealType" : @(self.mealType),
                   @"diningHallType" : @(self.selectedDiningHall.type),
                   };
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:payload forKey:@"defaultMenuInfo"];
    [defaults synchronize];
}

-(void)restoreMenuSettingsFromUserDefaults
{
    NSDictionary *payload = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"defaultMenuInfo"];
    
    if (!payload)
        return;
    
    self.selectedDate = payload[@"date"];
    self.mealType = (MMMealType)[payload[@"mealType"] intValue];
    self.selectedDiningHall = [MMDiningHall diningHallOfType:(MMDiningHallType)[payload[@"diningHallType"] intValue]];
}

#pragma mark - OptionsViewControllerDelegate Methods

-(void)optionsViewControllerWillDismiss:(OptionsViewController *)controller
{
    self.selectedDiningHall = controller.selectedDiningHall;
    self.selectedDate = controller.selectedDate;
    self.mealType = controller.mealType;
    
    [self reloadMenu];
    
    [self writeMenuSettingsToUserDefaults];
}

@end

@interface MealNutritionSegue : UIStoryboardSegue
@end

@implementation MealNutritionSegue

-(void)perform
{
    DiningMenuViewController *menu = self.sourceViewController;
    MealNutritionViewController *nutrition = self.destinationViewController;
    
    menu.mealNutrition = nutrition;
    nutrition.diningMenu = menu;
    
    UIView *superview = [UIApplication sharedApplication].windows[0];
    
    CGRect rect = superview.frame;
    rect.origin = CGPointMake(0, rect.size.height - menu.footerView.frame.size.height);
//    rect.origin = [menu.footerView convertPoint:CGPointZero toView:superview];
    
    nutrition.view.frame = rect;
    nutrition.view.userInteractionEnabled = NO;
    nutrition.navigationBar.alpha = 0.0;
    
    [superview addSubview:nutrition.view];
}

@end
