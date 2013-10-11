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
    
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 2.0, 0, 2.0);
    self.tableView.rowHeight = 25.0f;
    self.tableView.contentInset = UIEdgeInsetsMake(-46.0, 0, 0, 0);
    
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

-(void)createCells
{
    UITableViewCell *cell;
    UILabel *label;
    
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"yo"];
    cell.textLabel.text = @"Nutrition Facts";
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:19.0];
    
    [self.cells addObject:cell];
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

@end
