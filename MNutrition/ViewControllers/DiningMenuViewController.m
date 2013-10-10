//
//  DiningMenuViewController.m
//  MNutrition
//
//  Created by David Quesada on 10/9/13.
//  Copyright (c) 2013 David Quesada. All rights reserved.
//

#import "DiningMenuViewController.h"
#import "OptionsViewController.h"
#import "AppDelegate.h"
#import "MMeals.h"

@interface DiningMenuViewController ()<OptionsViewControllerDelegate>

@property NSArray *courses;
@property (weak) IBOutlet UITableView *tableView;

@end

@implementation DiningMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.edgesForExtendedLayout = UIRectEdgeAll;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.courses = [AppDelegate mainInstance].coursesForActiveMeal;
    [self.tableView reloadData];
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

#pragma mark - OptionsViewControllerDelegate Methods

-(void)optionsViewControllerWillDismiss:(OptionsViewController *)controller
{
    self.selectedDiningHall = controller.selectedDiningHall;
    self.selectedDate = controller.selectedDate;
    self.mealType = controller.mealType;
    
    self.navigationItem.title = self.selectedDiningHall.name;
    self.courses = [[self.selectedDiningHall menuInformationForDate:self.selectedDate] coursesForMeal:self.mealType];
    [self.tableView reloadData];
}

@end
