//
//  DiningMenuViewController.m
//  MNutrition
//
//  Created by David Quesada on 10/9/13.
//  Copyright (c) 2013 David Quesada. All rights reserved.
//

#import "DiningMenuViewController.h"
#import "AppDelegate.h"
#import "MMeals.h"

@interface DiningMenuViewController ()

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

@end
