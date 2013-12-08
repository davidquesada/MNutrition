//
//  DQNutritionView.m
//  MNutrition
//
//  Created by David Quesada on 10/11/13.
//  Copyright (c) 2013 David Quesada. All rights reserved.
//

#import "DQNutritionView.h"

@interface SpacerCell : UITableViewCell
@property CGFloat spacing;
-(instancetype)initWithSpacing:(CGFloat)spacing;
@end

@interface SeparatorCell : SpacerCell
@property UIEdgeInsets insets;
-(instancetype)initWithSpacing:(CGFloat)spacing color:(UIColor *)color insets:(UIEdgeInsets)insets;
@end



typedef NS_ENUM(NSInteger, CellTag)
{
    CellTagPrimary = 100,
    CellTagSecondary = 200,
    CellTagOther = 300,
};

@interface DQNutritionView ()<UITableViewDataSource, UITableViewDelegate>

@property UITableView *tableView;
@property NSMutableArray *cells;

@property UIFont *primaryLabelFont;
@property UIFont *secondaryLabelFont;
@property UIFont *valueFont;

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
    self.backgroundColor = [UIColor colorWithWhite:.97 alpha:1.0];
    CGRect frame = CGRectInset(self.bounds, 5, 0);
    self.tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self addSubview:self.tableView];
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)])
        self.tableView.separatorInset = UIEdgeInsetsMake(0, 2.0, 0, 2.0);
    self.tableView.contentInset = UIEdgeInsetsMake(12.0, 0, 0, 0);
    
    self.separatorColor = [UIColor blueColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tableView.backgroundColor = [UIColor clearColor];
    
    self.clipsToBounds = NO;
    
    self.primaryLabelFont = [UIFont boldSystemFontOfSize:18];
    self.secondaryLabelFont = [UIFont systemFontOfSize:18];
    self.valueFont = [UIFont systemFontOfSize:18];
}

-(void)setNutritionInfo:(id)nutritionInfo
{
    _nutritionInfo = nutritionInfo;
    
    self.cells = [[NSMutableArray alloc] init];
    [self createCells];
    [self.tableView reloadData];
}

-(UITableViewCell *)createCellWithPropertyName:(NSString *)propertyName label:(NSString *)label suffix:(NSString *)suffix indented:(BOOL)indented
{
    if (suffix == nil)
        suffix = @"";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"IM A CELL!"];
    
    
    id attr1 = @{ NSFontAttributeName : self.primaryLabelFont, NSForegroundColorAttributeName : [UIColor blackColor] };
    id attr2 = @{ NSFontAttributeName : self.valueFont, NSForegroundColorAttributeName : [UIColor darkGrayColor] };
    
    
    if (indented)
    {
        cell.indentationLevel = 3;
        attr1 = [attr1 mutableCopy];
        attr1[NSFontAttributeName] = self.secondaryLabelFont;
    }
    
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:label attributes:attr1];
    
    NSString *valueText = [NSString stringWithFormat:@"  %@%@", [[(id)self.nutritionInfo valueForKey:propertyName] description], suffix];
    [string appendAttributedString:[[NSAttributedString alloc] initWithString:valueText attributes:attr2]];
    cell.textLabel.attributedText = string;
    
    cell.tag = (indented ? CellTagSecondary : CellTagPrimary);
    
    int percent = [[[self nutritionInfo] percentages][propertyName] intValue];
    if (percent)
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d%%", percent];
    else
        cell.detailTextLabel.text = @"0%";
    
    return cell;
}

-(void)createCells
{
#define ADD(cell)   [self.cells addObject:cell]
#define MAKE_CELL(propName,Label,Suffix,indent) ADD([self createCellWithPropertyName:propName label:Label suffix:Suffix indented:indent])
#define SPACER(Spacing) ADD([[SpacerCell alloc] initWithSpacing:Spacing])
    
#define SEP(Height,Color,Left,Right) ADD([[SeparatorCell alloc] initWithSpacing:Height color:Color insets:UIEdgeInsetsMake(0,(Left),0,(Right))])
#define SEPARATOR(Height,Color) ADD([[SeparatorCell alloc] initWithSpacing:Height color:Color insets:UIEdgeInsetsZero])
    
#define REMOVE_DV() [[self.cells lastObject] detailTextLabel].text = nil
    
    UITableViewCell *cell;
    
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"yo"];
    cell.textLabel.text = @"Nutrition Facts";
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:22];
    [self.cells addObject:cell];
    
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"yo"];
    if ([self.nutritionInfo servingSize].length)
    {
        if ([self.nutritionInfo portionSize])
            cell.textLabel.text = [NSString stringWithFormat:@"Serving Size: %@ (%d g)", [self.nutritionInfo servingSize], [self.nutritionInfo portionSize]];
        else
            cell.textLabel.text = [NSString stringWithFormat:@"Serving Size: %@", [self.nutritionInfo servingSize]];
    }
    cell.textLabel.textColor = [UIColor grayColor];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    [self.cells addObject:cell];
    
    
    SPACER(8);
    
    int ds = 14; // Default spacing on either side of separator.
    int is = 32; // Left spacing for indented rows.
    
    id sepcol = [UIColor lightGrayColor]; // Separator color.
    
#define DEFAULT_THIN_SEP() SEP(.5, sepcol, ds, ds)
#define INDENTED_THIN_SEP() SEP(.5, sepcol, is, ds)
    
    SEP(2.5, sepcol, ds, ds);
    
    MAKE_CELL(@"calories", @"Calories", nil, NO);
    REMOVE_DV();
    INDENTED_THIN_SEP();
    MAKE_CELL(@"caloriesFromFat", @"Calories from Fat", nil, YES);
    REMOVE_DV();
    
    SEP(2.5, sepcol, ds, ds);
    
    MAKE_CELL(@"fat", @"Total Fats", @" g", NO);
    INDENTED_THIN_SEP();
    MAKE_CELL(@"saturatedFat", @"Saturated Fat", @" g", YES);
    INDENTED_THIN_SEP();
    MAKE_CELL(@"transFat", @"Trans Fat", @" g", YES);
    
    DEFAULT_THIN_SEP();
    MAKE_CELL(@"cholesterol", @"Cholesterol", @" mg", NO);
    DEFAULT_THIN_SEP();
    MAKE_CELL(@"sodium", @"Sodium", @" mg", NO);
    DEFAULT_THIN_SEP();
    MAKE_CELL(@"carbohydrates", @"Total Carbohydrates", @" g", NO);
    INDENTED_THIN_SEP();
    MAKE_CELL(@"fiber", @"Dietary Fiber", @" g", YES);
    INDENTED_THIN_SEP();
    MAKE_CELL(@"sugar", @"Sugars", @" g", YES);
    REMOVE_DV();
    
    DEFAULT_THIN_SEP();
    MAKE_CELL(@"protein", @"Protein", @" g", NO);
    REMOVE_DV();
}

#pragma mark - Appearance Properties

-(void)setSeparatorColor:(UIColor *)separatorColor
{
    _separatorColor = separatorColor;
    self.tableView.separatorColor = separatorColor;
}

#pragma mark - UITableViewDataSource / Delegate Methods

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
}

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

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id cell = self.cells[indexPath.row];
    if ([cell isKindOfClass:[SpacerCell class]])
        return [cell spacing];
    
    if ([cell tag] == CellTagPrimary)
        return 28;
    if ([cell tag] == CellTagSecondary)
        return 28;
    
    return 24;
}

@end


@implementation SpacerCell
-(instancetype)initWithSpacing:(CGFloat)spacing
{
    if ((self = [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[[self class]description]]))
    {
        self.spacing = spacing;
    }
    return self;
}
@end


@implementation SeparatorCell
-(instancetype)initWithSpacing:(CGFloat)spacing color:(UIColor *)color insets:(UIEdgeInsets)insets
{
    if ((self = [self initWithSpacing:spacing]))
    {
        self.contentView.backgroundColor = color;
        self.insets = insets;
    }
    return self;
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    self.contentView.frame = UIEdgeInsetsInsetRect(self.contentView.superview.bounds, self.insets);
}
@end
