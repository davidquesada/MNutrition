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

@end

@implementation DiningMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.footerView.clipsToBounds = NO;
    self.originalFooterFrame = self.footerView.frame;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.courses = [AppDelegate mainInstance].coursesForActiveMeal;
    [self.tableView reloadData];
    
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

-(IBAction)showMealNutrition:(id)sender
{
    [self setNutritionVisible:YES];
}

-(void)addPanGestureToView:(UIView *)view
{
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    view.gestureRecognizers = @[ pan ];
}

#pragma mark - OptionsViewControllerDelegate Methods

-(void)optionsViewControllerWillDismiss:(OptionsViewController *)controller
{
    self.selectedDiningHall = controller.selectedDiningHall;
    self.selectedDate = controller.selectedDate;
    self.mealType = controller.mealType;
    
    self.navigationItem.title = self.selectedDiningHall.name;
    self.courses = [[self.selectedDiningHall menuInformationForDate:self.selectedDate] coursesForMeal:self.mealType];
    [self.tableView reloadData];
    [self.tableView scrollRectToVisible:CGRectMake(0, 44, 1, 1) animated:NO];
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
