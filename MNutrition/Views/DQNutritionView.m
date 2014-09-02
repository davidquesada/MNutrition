//
//  DQNutritionView.m
//  MNutrition
//
//  Created by David Quesada on 10/11/13.
//  Copyright (c) 2013 David Quesada. All rights reserved.
//

#import "DQNutritionView.h"

static BOOL useTextAttributesForDQNutritionView = NO;

@interface SpacerCell : UITableViewCell
@property CGFloat spacing;
-(instancetype)initWithSpacing:(CGFloat)spacing;
@end

@interface SeparatorCell : SpacerCell
@property UIEdgeInsets insets;
-(instancetype)initWithSpacing:(CGFloat)spacing color:(UIColor *)color insets:(UIEdgeInsets)insets;
@end

@interface PropertyCell : UITableViewCell
@property NSString *label;
@property NSString *suffix;
@property NSString *propertyName;
@property BOOL hidePercentage;
-(void)showPropertyForNutritionObject:(id<DQNutritionObject>)object;
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
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
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
    useTextAttributesForDQNutritionView = [[[UIDevice currentDevice] systemVersion] intValue] >= 6;
}

-(void)setNutritionInfo:(id)nutritionInfo
{
    _nutritionInfo = nutritionInfo;
    
    if (!self.cells)
    {
        self.cells = [[NSMutableArray alloc] init];
        [self createCells];
    }
    for (PropertyCell *cell in self.cells)
    {
        if (![cell isKindOfClass:[PropertyCell class]])
            continue;
        [cell showPropertyForNutritionObject:nutritionInfo];
    }
    [self.tableView reloadData];
}

-(UITableViewCell *)createCellWithPropertyName:(NSString *)propertyName label:(NSString *)label suffix:(NSString *)suffix indented:(BOOL)indented
{
    if (suffix == nil)
        suffix = @"";
    PropertyCell *cell = [[PropertyCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"IM A CELL!"];
    
//    [cell showPropertyForNutritionObject:self.nutritionInfo];
    cell.propertyName = propertyName;
    cell.label = label;
    cell.suffix = suffix;
    if (indented)
        cell.indentationLevel = 3;
    
    cell.tag = (indented ? CellTagSecondary : CellTagPrimary);
    
    return cell;
}

-(void)createCells
{
#define ADD(cell)   [self.cells addObject:cell]
#define MAKE_CELL(propName,Label,Suffix,indent) ADD([self createCellWithPropertyName:propName label:Label suffix:Suffix indented:indent])
#define SPACER(Spacing) ADD([[SpacerCell alloc] initWithSpacing:Spacing])
    
#define SEP(Height,Color,Left,Right) ADD([[SeparatorCell alloc] initWithSpacing:Height color:Color insets:UIEdgeInsetsMake(0,(Left),0,(Right))])
#define SEPARATOR(Height,Color) ADD([[SeparatorCell alloc] initWithSpacing:Height color:Color insets:UIEdgeInsetsZero])
    
#define REMOVE_DV() [[self.cells lastObject] setHidePercentage:YES]
    
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
            cell.textLabel.text = [NSString stringWithFormat:@"Serving Size: %@ (%d g)", [self.nutritionInfo servingSize], (int)[self.nutritionInfo portionSize]];
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
    
    [self.cells setValue:@(UITableViewCellSelectionStyleNone) forKey:@"selectionStyle"];
}

#pragma mark - Appearance Properties

-(void)setSeparatorColor:(UIColor *)separatorColor
{
    _separatorColor = separatorColor;
    self.tableView.separatorColor = separatorColor;
}

-(BOOL)scrollEnabled
{
    return _tableView.scrollEnabled;
}

-(void)setScrollEnabled:(BOOL)scrollEnabled
{
    _tableView.scrollEnabled = scrollEnabled;
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

@implementation PropertyCell

-(UIFont *)primaryLabelFont
{
    UIFont *f = nil;
    if (!f)
        f = [UIFont boldSystemFontOfSize:18];
    return f;
}

-(UIFont *)secondaryLabelFont
{
    UIFont *f = nil;
    if (!f)
        f = [UIFont systemFontOfSize:18];
    return f;
}

-(UIFont *)valueFont
{
    UIFont *f = nil;
    if (!f)
        f = [UIFont systemFontOfSize:18];
    return f;
}

-(void)showPropertyForNutritionObject:(id<DQNutritionObject>)object
{
    NSDictionary *attr1, *attr2;
    
    // These features are only available in iOS 6.0+
    if (useTextAttributesForDQNutritionView)
    {
        attr1 = @{ NSFontAttributeName : self.primaryLabelFont, NSForegroundColorAttributeName : [UIColor blackColor] };
        attr2 = @{ NSFontAttributeName : self.valueFont, NSForegroundColorAttributeName : [UIColor darkGrayColor] };
    }
    else
    {
        NSLog(@"Text attributes not available");
        attr1 = attr2 = @{};
    }

    if (useTextAttributesForDQNutritionView)
    {
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:self.label attributes:attr1];

        NSString *valueText = [NSString stringWithFormat:@"  %@%@", [[(id)object valueForKey:self.propertyName] description], self.suffix];
        [string appendAttributedString:[[NSAttributedString alloc] initWithString:valueText attributes:attr2]];
        self.textLabel.attributedText = string;
    } else
    {
        NSString *valueText = [NSString stringWithFormat:@"%@: %@%@", self.label, [[(id)object valueForKey:self.propertyName] description], self.suffix];
        self.textLabel.text = valueText;
    }
    
    if (self.hidePercentage)
        self.detailTextLabel.text = @"";
    else
    {
        id percentObject = [object percentages][self.propertyName];
        int percent = [percentObject intValue];
        if (percent)
            self.detailTextLabel.text = [NSString stringWithFormat:@"%d%%", percent];
        else
            self.detailTextLabel.text = @"0%";
    }
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
