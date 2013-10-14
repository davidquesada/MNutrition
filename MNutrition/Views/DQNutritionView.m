//
//  DQNutritionView.m
//  MNutrition
//
//  Created by David Quesada on 10/11/13.
//  Copyright (c) 2013 David Quesada. All rights reserved.
//

#import "DQNutritionView.h"

typedef NS_ENUM(NSInteger, CellTag)
{
    CellTagNone,
    CellTagTitle,
    CellTagOther
};

@interface DQNutritionView ()<UITableViewDataSource, UITableViewDelegate>

@property UITableView *tableView;
@property NSMutableArray *cells;

@end

@implementation DQNutritionView

//@synthesize nutritionInfo = _nutritionInfo;

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

-(void)setup
{
    self.tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self addSubview:self.tableView];
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)])
        self.tableView.separatorInset = UIEdgeInsetsMake(0, 2.0, 0, 2.0);
    self.tableView.rowHeight = 25.0f;
    self.tableView.contentInset = UIEdgeInsetsMake(20.0, 0, 0, 0);
    
    self.separatorColor = [UIColor blueColor];
    
    self.layer.borderColor = [UIColor blackColor].CGColor;
    self.layer.borderWidth = 1.5f;
    self.clipsToBounds = NO;
}

-(void)setNutritionInfo:(id)nutritionInfo
{
    _nutritionInfo = nutritionInfo;
    
    self.cells = [[NSMutableArray alloc] init];
    [self createCells];
    [self.tableView reloadData];
}

-(UITableViewCell *)createCellWithPropertyName:(NSString *)propertyName label:(NSString *)label suffix:(NSString *)suffix
{
    if (suffix == nil)
        suffix = @"";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"IM A CELL!"];
    
    cell.textLabel.text = label;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@%@", [[(id)self.nutritionInfo valueForKey:propertyName] description], suffix];
    
    return cell;
}

-(void)createCells
{
    UITableViewCell *cell;
    
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"yo"];
    cell.textLabel.text = @"Nutrition Facts";
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:19.0];
    
    [self.cells addObject:cell];
    
    [self.cells addObject:[self createCellWithPropertyName:@"calories" label:@"Calories" suffix:nil]];
    [self.cells addObject:[self createCellWithPropertyName:@"caloriesFromFat" label:@"Calories from Fat" suffix:nil]];
    [self.cells addObject:[self createCellWithPropertyName:@"fat" label:@"Total Fats" suffix:@" g"]];
    [self.cells addObject:[self createCellWithPropertyName:@"saturatedFat" label:@"Saturated Fat" suffix:@" g"]];
    [self.cells addObject:[self createCellWithPropertyName:@"transFat" label:@"Trans Fat" suffix:@" g"]];
    [self.cells addObject:[self createCellWithPropertyName:@"cholesterol" label:@"Cholesterol" suffix:@" mg"]];
    [self.cells addObject:[self createCellWithPropertyName:@"sodium" label:@"Sodium" suffix:@" mg"]];
    [self.cells addObject:[self createCellWithPropertyName:@"carbohydrates" label:@"Total Carbohydrates" suffix:@" g"]];
    [self.cells addObject:[self createCellWithPropertyName:@"fiber" label:@"Dietary Fiber" suffix:@" g"]];
    [self.cells addObject:[self createCellWithPropertyName:@"sugar" label:@"Sugars" suffix:@" g"]];
    [self.cells addObject:[self createCellWithPropertyName:@"protein" label:@"Protein" suffix:@" g"]];
    
}

#pragma mark - Appearance Properties

-(void)setSeparatorColor:(UIColor *)separatorColor
{
    _separatorColor = separatorColor;
    self.tableView.separatorColor = separatorColor;
}

#pragma mark - UITableViewDataSource / Delegate Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.cells.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.cells[indexPath.row];
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

@end
