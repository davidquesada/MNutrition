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
#import "DQNutritionView.h"
#import "NSDate+Increment.h"
#import "CompositeNutritionObject.h"
#import <CoreLocation/CoreLocation.h>
#import "UIView+SafeScreenshot.h"
#import "SVProgressHUD.h"
#import "UserDefaults.h"

@interface DiningMenuViewController ()<OptionsViewControllerDelegate, CLLocationManagerDelegate>
{
    BOOL _hasNotice;
    
    UIView *_noticeView;
    UILabel *_noticeLabel;
    UIColor *_noticeBackgroundColor;
    
    BOOL _isLookingForLocation;
    BOOL _isMealNutritionVisible;
    
    UIPopoverController *_pop;
}

@property NSArray *courses;
@property NSArray *previousCourses;
@property(weak) IBOutlet UITableView *tableView;
@property(weak) IBOutlet UIView *footerView;
@property(weak) IBOutlet UIView *footerContentsView;
@property(weak) IBOutlet UIView *centeredFooterContentsView;


@property(weak) IBOutlet UILabel *caloriesHeaderLabel;
@property(weak) IBOutlet UILabel *caloriesLabel;
@property(weak) IBOutlet UILabel *fatLabel;
@property(weak) IBOutlet UILabel *proteinLabel;
@property(weak) IBOutlet UILabel *carbsLabel;


@property(weak) IBOutlet NSLayoutConstraint *footerConstraint;
@property(weak) IBOutlet NSLayoutConstraint *tableSlideConstraint;

@property CGRect startingFooterRect;
@property MealNutritionViewController *mealNutrition;

@property NSArray *myOriginalLeftItems;
@property CGRect originalFooterFrame;

@property DQNavigationBarLabel *navBarLabel;

@property CLLocationManager *locationManager;
@property CompositeNutritionObject *nutritionObject;

@property(weak) MMMenuItem *selectedMenuItem;
@property   UIRefreshControl *refreshControl;

-(void)setNotice:(NSString *)notice reloadTableView:(BOOL)reload;
-(void)updateNavBarLabel;

@property(weak) IBOutlet UIPanGestureRecognizer *footerViewPanGesture;
@property(weak) IBOutlet UITapGestureRecognizer *footerViewTapGesture;

@end

@implementation DiningMenuViewController

-(void)loadView
{
    [super loadView];
    self.originalFooterFrame = self.footerView.frame;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.footerView.clipsToBounds = NO;
    
    self.navBarLabel = [[DQNavigationBarLabel alloc] init];
    self.navigationItem.titleView = self.navBarLabel;
    [self updateNavBarLabel];
    
    self.locationManager = [[CLLocationManager alloc] init];
    
    //[self restoreMenuSettingsFromUserDefaults];
    self.nutritionObject = [[CompositeNutritionObject alloc] init];
    
    self.footerConstraint.constant = -self.footerView.frame.size.height;

    // If we were able to restore a dining hall, date, and meal from the user defaults,
    // then let's try to fetch that from the server again.
    if (self.selectedDiningHall)
        [self fetchMenuInformation:^{
            [self reloadMenu];
        }];
    
    if (![AppDelegate isIOS7])
    {
        self.tableView.editing = YES;
    }
    
    if ([AppDelegate isIOS6])
    {
        self.refreshControl = [[UIRefreshControl alloc] init];
        [self.tableView addSubview:self.refreshControl];
        self.refreshControl.backgroundColor = [UIColor whiteColor];
        [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    }
    if (![AppDelegate isIOS7])
    {
        // Helvetica Neue Thin isn't available on iOS < 7, so let's grab the same font
        // as the "Calories" text, crank up the size a little bit, and use that instead.
        CGFloat dataFontSize = self.caloriesLabel.font.pointSize * 1.5;
        UIFont *baseFont = self.caloriesHeaderLabel.font;
        UIFont *newFont = [baseFont fontWithSize:dataFontSize];
        
        for (UILabel *lbl in @[ self.caloriesLabel, self.fatLabel, self.proteinLabel, self.carbsLabel ])
            lbl.font = newFont;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.mealNutrition)
        [self performSegueWithIdentifier:@"showMealNutrition" sender:nil];
    
    // Gray out the tableview if there hasn't been a dining hall set yet.
    // (Happens on iPad when initially loading menu or on first app launch)
    if (!_selectedDiningHall)
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setNotice:@"Select a dining hall." reloadTableView:NO];
        });
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)dealloc
{
    [self.mealNutrition.view removeFromSuperview];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showMenuItem"])
    {
        MenuItemDetailViewController *controller = segue.destinationViewController;
        controller.menuItem = self.selectedMenuItem;
    }
}

-(void)showMenuItem
{
    [self performSegueWithIdentifier:@"showMenuItem" sender:nil];
}

-(void)reloadMenu
{
    [self reloadMenu:YES];
}

-(void)reloadMenu:(BOOL)animated
{
    [self updateOptionsViewController];
    [self updateNavBarLabel];
    NSArray *newCourses = [[self.selectedDiningHall menuInformationForDate:self.selectedDate] coursesForMeal:self.mealType];
    
    // TODO: We should probably move the "notice" functionality to the MMeals library, rather than
    // extracting the notices in the application, like we do here.
    // Also, check out East Quad for Breakfast, Sep 1, 2014. There are no courses and no notices, so
    // the update appears as "Unable to load menu", when that doesn't actually reflect the situation.
    _hasNotice = [[[newCourses firstObject] name] isEqualToString:@"notice"];
    if (_hasNotice)
    {
        // UUUUUUGLY!
        NSString *notice = [(MMMenuItem *)[[[newCourses firstObject] items] firstObject] name];
        [self setNotice:notice reloadTableView:NO];
    } else
    {
        [self setNotice:nil reloadTableView:NO];
    }
    
    if (!newCourses.count)
        [self setNotice:@"Unable to load menu." reloadTableView:NO];
    
    self.courses = newCourses;
    [self.tableView reloadData];
    
    if (self.courses != self.previousCourses)
    {
        [self.nutritionObject removeAllObjects];
        [self updateNutritionDisplays:animated];
    }
    self.previousCourses = self.courses;
    [SVProgressHUD dismiss];
    
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
}

-(void)setNotice:(NSString *)notice reloadTableView:(BOOL)reload
{
    if (!_noticeView)
    {
        _noticeView = [[UIView alloc] initWithFrame:CGRectZero];
        
        _noticeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _noticeLabel.numberOfLines = 0;
        _noticeLabel.font = [UIFont systemFontOfSize:22];
        _noticeLabel.textColor = [UIColor grayColor];
        _noticeLabel.textAlignment = NSTextAlignmentCenter;
        _noticeLabel.backgroundColor = [UIColor clearColor];
        _noticeLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [_noticeView addSubview:_noticeLabel];
        _noticeBackgroundColor = [UIColor colorWithWhite:.9 alpha:1.0];
    }
    
    if (notice.length)
    {
        _hasNotice = YES;
        
        // Resize the views.
        _noticeView.frame = UIEdgeInsetsInsetRect(_tableView.bounds, _tableView.contentInset);
        _noticeLabel.frame = UIEdgeInsetsInsetRect(_noticeView.bounds, UIEdgeInsetsMake(0, 30, _noticeView.bounds.size.height / 4, 30));
        
        _noticeLabel.text = notice;
        _tableView.tableHeaderView = _noticeView;
        
        self.tableView.backgroundColor = _noticeBackgroundColor;
        self.refreshControl.backgroundColor = _noticeBackgroundColor;
        
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    else
    {
        _hasNotice = NO;
        self.tableView.tableHeaderView = nil;
        self.tableView.backgroundColor = [UIColor whiteColor];
        self.refreshControl.backgroundColor = [UIColor whiteColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    
    if (reload)
        [self.tableView reloadData];
}

-(void)updateNavBarLabel
{
    static NSDateFormatter *formatter;
    if (!formatter)
    {
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateStyle = NSDateFormatterMediumStyle;
    }
    
    if (_selectedDiningHall)
    {
        self.navBarLabel.text = self.selectedDiningHall.name;
        self.navBarLabel.subtitle = [NSString stringWithFormat:@"%@, %@", MMMealTypeToString(self.mealType), [formatter stringFromDate:self.selectedDate]];
    }
    else
    {
        self.navBarLabel.text = nil;
        self.navBarLabel.subtitle = nil;
    }
}

-(void)updateNutritionDisplays:(BOOL)animated
{
    self.caloriesLabel.text = [NSString stringWithFormat:@"%d", self.nutritionObject.calories];
    self.fatLabel.text = [NSString stringWithFormat:@"%d g", self.nutritionObject.fat];
    self.proteinLabel.text = [NSString stringWithFormat:@"%d g", self.nutritionObject.protein];
    self.carbsLabel.text = [NSString stringWithFormat:@"%d g", self.nutritionObject.carbohydrates];
    
    if ([self.nutritionObject itemCount] == 0)
        [self setFooterViewVisible:NO animated:animated];
    else
        [self setFooterViewVisible:YES animated:animated];
    
    self.mealNutrition.nutritionView.nutritionInfo = self.nutritionObject;
}

-(CGRect)footerViewFrame:(BOOL)visible
{
    if (visible)
    {
        CGRect frame = self.footerView.bounds;
        frame.origin.y = self.view.frame.size.height - frame.size.height;
        //frame = [self.footerView.superview convertRect:frame fromView:self.view];
        return frame;
    }
    else
    {
        return CGRectMake(self.footerView.frame.origin.x, self.footerView.superview.frame.size.height, self.footerView.frame.size.width, self.footerView.frame.size.height);
    }
}

-(void)setFooterViewVisible:(BOOL)visible animated:(BOOL)animated
{
    void (^beforeAnimations)() = ^{
        self.footerViewPanGesture.enabled = visible;
        self.footerViewTapGesture.enabled = visible;
        self.footerConstraint.constant = visible ? 0 : (-1 * self.footerView.frame.size.height);
    };
    
    void (^animations)() = ^{
        [self.footerView.superview layoutIfNeeded];
        
        CGFloat bottomInset = 0.0;
        
        bottomInset = (visible ? self.footerView.frame.size.height : 0);
        
        UIEdgeInsets insets;
        
        insets = self.tableView.scrollIndicatorInsets;
        insets.bottom = bottomInset;
        self.tableView.scrollIndicatorInsets = insets;
        
        insets = self.tableView.contentInset;
        insets.bottom = bottomInset;
        self.tableView.contentInset = insets;
        
        if (!visible)
            self.mealNutrition.view.frame = CGRectOffset(self.mealNutrition.view.bounds, 0, self.view.frame.size.height);
    };
    
    // We want to defer the actual animations to the next update cycle, otherwise
    // the call to [view layoutIfNeeded] can cause the table view to animate weird things,
    // like having all the info buttons fly from the left side of the screen to the right.
    dispatch_async(dispatch_get_main_queue(), ^{
        beforeAnimations();
        if (animated)
            [UIView animateWithDuration:.13f animations:animations];
        else
            animations();
    });
}

-(IBAction)pan:(UIPanGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        self.startingFooterRect = self.footerView.frame;
        self.tableView.userInteractionEnabled = NO;
    }
    
    CGPoint trans = [sender translationInView:self.footerView];
//    NSLog(@"trans.x: %d, trans.y: %d", (int)trans.x, (int)trans.y);
    trans.x = 0;
    
    CGRect rect = self.startingFooterRect;
    rect = CGRectOffset(rect, 0, trans.y);
    
//    float progress = [self setFooterViewFrame:rect];
    float progress;
    if (!_isMealNutritionVisible)
        progress = [self setFooterViewYFromBottom:-trans.y];
    else
        progress = [self setFooterViewYFromTop:trans.y];
    
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
    
    switch (sender.state) {
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
            self.footerContentsView.alpha = 1.0f;
            self.tableView.userInteractionEnabled = YES;
            break;
        default:break;
    }
}

-(float)setFooterViewYFromTop:(CGFloat)y
{
    CGFloat bottomSpace = self.view.frame.size.height - self.footerView.frame.size.height - y;
    return [self setFooterViewYFromBottom:bottomSpace];
}

-(float)setFooterViewYFromBottom:(CGFloat)y
{
    self.footerConstraint.constant = y;
    
    CGFloat svh = self.footerView.superview.frame.size.height - self.footerView.frame.size.height;
    CGFloat inv_y = svh - y;
    
    CGFloat progress = inv_y / svh;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return progress;
    
    // Move the nutrition view.
    CGRect rect;
    CGPoint point = CGPointMake(0, self.view.frame.size.height - y - self.footerView.frame.size.height);
    
//    point = [self.mealNutrition.view.superview convertPoint:point fromView:self.footerView.window];
    point = [self.mealNutrition.view.superview convertPoint:point fromView:self.view];
    
    rect = self.mealNutrition.view.frame;
    rect.origin = point;
    
    if (![AppDelegate isIOS7])
    {
        rect.origin.y -= 64;
        self.mealNutrition.view.alpha = (1.0f - progress);
    }
    
    // Compensate for a potentially enlarged status bar.
    rect.origin.y -= self.mealNutrition.view.superview.frame.origin.y;
    
    // Keep the view from sliding above the top of the screen.
    rect.origin.y = MAX(0, rect.origin.y);
    
    self.mealNutrition.view.frame = rect;
    
    
    self.mealNutrition.navigationBar.alpha = (1.0f - progress);
    self.footerContentsView.alpha = progress;
    
    return progress;
}

// Sets whether the meal nutrition is going to be shown.
-(void)setNutritionVisible:(BOOL)visible
{
    _isMealNutritionVisible = visible;
    float time = 0.25f;
    [UIView animateWithDuration:time animations:^{
        if (visible)
        {
            CGRect rect = self.footerView.frame;
            rect.origin = CGPointZero;
           
            [self setFooterViewYFromBottom:(self.view.frame.size.height - self.footerView.frame.size.height)];
            self.mealNutrition.view.userInteractionEnabled = YES;
        }
        else
        {
            BOOL shouldShowFooterView = self.nutritionObject.itemCount > 0;
            if (shouldShowFooterView)
                [self setFooterViewYFromBottom:0];
            else
                [self setFooterViewYFromBottom:-self.footerView.frame.size.height];
            self.mealNutrition.view.userInteractionEnabled = NO;
        }
        
        [self.view layoutIfNeeded];
    }];
}

-(void)addPanGestureToView:(UIView *)view
{
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    view.gestureRecognizers = @[ pan ];
}

-(void)cloneTransitionToLeft:(BOOL)toLeft
{
    UIView *viewToSnapshot = self.tableView;
    
    if (self.nutritionObject.itemCount)
        viewToSnapshot = self.view;
    
    UIView *temp;
    
    if ([AppDelegate isIOS7])
        temp = [viewToSnapshot snapshotViewAfterScreenUpdates:NO];
    else
        temp = [viewToSnapshot screenshotView];
        
    [self.view insertSubview:temp aboveSubview:viewToSnapshot];
    
    // Force the footer view to go away.
    self.footerConstraint.constant = -self.footerView.frame.size.height;
    
    // I can't ever decide if I want parallax or not.
    CGFloat ParallaxAmount = self.tableView.frame.size.width;
    ParallaxAmount = 0.0f;
    
    self.tableSlideConstraint.constant = ParallaxAmount * (toLeft ? 1 : -1);
    [self.footerView.superview layoutIfNeeded];
    
    self.tableSlideConstraint.constant = 0;
    
    [UIView animateWithDuration:0.25f animations:^{
        [self.view layoutIfNeeded];
        CGRect rect = temp.frame;
        rect.origin.x = (toLeft ? -1.0f : 1.0f) * rect.size.width;
        temp.frame = rect;
        
    } completion:^(BOOL finished) {
        [temp removeFromSuperview];
    }];
}

-(void)fetchMenuInformation:(void (^)())completion
{
    id data = [self.selectedDiningHall menuInformationForDate:self.selectedDate];
    
    if (data || (self.selectedDiningHall == nil))
    {
        completion();
        return;
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeNone];
    
    [self.selectedDiningHall fetchMenuInformationForDate:self.selectedDate completion:^{
        [SVProgressHUD dismiss];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        completion();
    }];
}

-(void)refresh:(id)sender
{
    [self.selectedDiningHall clearCachedMenuInformationForDate:self.selectedDate];
    [self fetchMenuInformation:^{
        [self.refreshControl endRefreshing];
        [self reloadMenu];
    }];
}

-(MMMenuItem *)menuItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.courses[indexPath.section] items][indexPath.row];
}

-(void)updateOptionsViewController
{
    self.optionsViewController.selectedDate = self.selectedDate;
    self.optionsViewController.selectedDiningHall = self.selectedDiningHall;
    self.optionsViewController.mealType = self.mealType;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        [self.optionsViewController writeOptionsToUI];
}

#pragma mark - IBActions

-(IBAction)goToCurrentMeal:(id)sender
{
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted)
    {
        self.selectedDate = [NSDate date];
        self.mealType = MMMealTypeFromTime(self.selectedDate);
        [self writeMenuSettingsToUserDefaults];
        
        [self fetchMenuInformation:^{
            [self reloadMenu];
        }];
        return;
    }
    
    _isLookingForLocation = YES;

#ifdef __IPHONE_8_0
    // New in iOS 8. You need to call this before using the locationManager, otherwise it fails silently.
    if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
        [_locationManager requestWhenInUseAuthorization];
#endif
    
    [self.locationManager startUpdatingLocation];
}

-(IBAction)moveToNextMeal:(id)sender
{
    if (!_selectedDiningHall)
        return;
    
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
        [self reloadMenu:NO];
        [self writeMenuSettingsToUserDefaults];
    }];
}

-(IBAction)moveToPreviousMeal:(id)sender
{
    if (!_selectedDiningHall)
        return;
    
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
        [self reloadMenu:NO];
        [self writeMenuSettingsToUserDefaults];
    }];
}

-(IBAction)showMealNutrition:(id)sender
{
    [self setNutritionVisible:YES];
}

-(IBAction)showMealNutritionInPopover:(id)sender
{
    self.mealNutrition.nutritionView.scrollEnabled = NO;
    self.mealNutrition.navigationBar.alpha = 1.0;
    self.mealNutrition.view.userInteractionEnabled = YES;
    [self.mealNutrition.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    
    if ([AppDelegate isIOS6])
        [self.mealNutrition.navigationBar setShadowImage:[UIImage new]];
    
    UIView *view = self.mealNutrition.view;
    [view removeFromSuperview];
    
    UIViewController *content = self.mealNutrition;
    _pop = [[UIPopoverController alloc] initWithContentViewController:content];
    
    UIView *parent = self.centeredFooterContentsView;
    CGRect rect = {0,0,1,1};
    rect.origin.x = parent.bounds.size.width / 2.0;
    
    [_pop presentPopoverFromRect:rect inView:parent permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
}

-(IBAction)showOptions:(id)sender
{
    [self updateOptionsViewController];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - UITableView

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
    if (_hasNotice)
        return 0;
    return self.courses.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MMMenuItem *item = [self menuItemAtIndexPath:indexPath];
    int count = [self.nutritionObject countOfItem:item];
    
    NSString *cellID = count ? @"menuItemCellSelected" : @"menuItemCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (![AppDelegate isIOS7])
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    
    cell.textLabel.text = item.name;
    
    if (count == 0)
        return cell;
    
    if (count == 1)
        cell.detailTextLabel.text = @"1 Serving";
    else
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d Servings", count];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MMMenuItem *item = [self menuItemAtIndexPath:indexPath];
    [self.nutritionObject addItem:item];
    [tableView reloadRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationMiddle];
    [self updateNutritionDisplays:YES];
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    self.selectedMenuItem = [self menuItemAtIndexPath:indexPath];
    
    if ([AppDelegate isIOS7])
    {
        // If we push the detail view while the table view is editing, there's a strange bug where the
        // interactive pop gesture is disabled in the detail view controller.
        NSTimeInterval delay = self.tableView.isEditing ? .6 : 0.0;
        [tableView setEditing:NO animated:YES];
        [self performSelector:@selector(showMenuItem) withObject:nil afterDelay:delay];
    } else
        [self showMenuItem];
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MMMenuItem *item = [self menuItemAtIndexPath:indexPath];
    if ([self.nutritionObject countOfItem:item] > 0)
        return UITableViewCellEditingStyleDelete;
    return UITableViewCellEditingStyleNone;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    MMMenuItem *item = [self menuItemAtIndexPath:indexPath];
    [self.nutritionObject removeItem:item];
    [self.tableView reloadRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self updateNutritionDisplays:YES];
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Remove";
}

/*
 This method is needed for the way I implemented iOS <7 compatibility.
 */
-(NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MMMenuItem *item = [self menuItemAtIndexPath:indexPath];
    if ([self.nutritionObject countOfItem:item] > 0 || (tableView == self.searchDisplayController.searchResultsTableView))
        return 0;
    return -1;
}

#pragma mark - CLLocationManagerDelegate Methods

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    [manager stopUpdatingLocation];
    
    if (!_isLookingForLocation)
        return;
    
    _isLookingForLocation = NO;
    
    self.selectedDate = [NSDate date];
    self.mealType = MMMealTypeFromTime(self.selectedDate);
    self.selectedDiningHall = [MMDiningHall diningHallClosestToLocation:newLocation];
    [self writeMenuSettingsToUserDefaults];
    
    [self fetchMenuInformation:^{
        [self reloadMenu];
    }];
}

#pragma mark - User Defaults functionality

-(void)writeMenuSettingsToUserDefaults
{
    UserDefaults *manager = [UserDefaults defaultManager];
    manager.date = self.selectedDate;
    manager.diningHall = self.selectedDiningHall;
    manager.mealType = self.mealType;
    [manager writeToUserDefaults];
}

-(void)restoreMenuSettingsFromUserDefaults
{
    UserDefaults *manager = [UserDefaults defaultManager];
    [manager readFromUserDefaults];
    self.selectedDiningHall = manager.diningHall;
    self.selectedDate = manager.date;
    self.mealType = manager.mealType;
}

#pragma mark - OptionsViewControllerDelegate Methods

-(void)optionsViewControllerDidChooseOptions:(OptionsViewController *)controller
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
    superview = ((UIWindow *)superview).rootViewController.view;
    
    CGRect rect = superview.bounds;
    rect.origin = CGPointMake(0, rect.size.height - menu.footerView.frame.size.height);
    
    nutrition.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    nutrition.view.frame = rect;
    nutrition.view.userInteractionEnabled = NO;
    nutrition.navigationBar.alpha = 0.0;
    
    
    // The iPad UI uses popovers instead, so we don't need to add the mealNutrition to any parent view.
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return;
    
    [superview addSubview:nutrition.view];
    [nutrition viewWillAppear:YES];
}

@end
