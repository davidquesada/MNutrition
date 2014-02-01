//
//  DQDateSlider.m
//  MNutrition
//
//  Created by David Quesada on 1/31/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "DQDateSlider.h"

NSDate *referenceDate()
{
    static NSDate *date = nil;
    if (!date)
        date = [NSDate dateWithTimeIntervalSince1970:0];
    return date;
}

static int indexFromDate(NSDate *date)
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comps = [cal components:NSDayCalendarUnit fromDate:referenceDate() toDate:date options:0];
    return [comps day];
}
static NSDate *dateFromIndex(int index)
{
    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
    dayComponent.day = index;
    
    NSCalendar *theCalendar = [NSCalendar currentCalendar];
    return [theCalendar dateByAddingComponents:dayComponent toDate:referenceDate() options:0];
}

@interface DQDateSliderCell : UICollectionViewCell
@property UILabel *label;
@property UILabel *dayLabel;
@property NSDate *date;
-(void)setProgress:(CGFloat)progress;
-(void)setDateValue:(int)value;
@end
@implementation DQDateSliderCell

+(NSString *)reuseIdentifier
{
    return @"DQDateSliderCell";
}

-(NSString *)reuseIdentifier
{
    return [self.class reuseIdentifier];
}

-(void)prepareForReuse
{
    self.contentView.transform = CGAffineTransformIdentity;
}

-(id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        frame.origin = CGPointZero;
        frame.origin.y = frame.size.height / 7.0;
        self.label = [[UILabel alloc] initWithFrame:frame];
        self.label.text = @"#YOLO";
        self.label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:24.0];
        self.label.backgroundColor = [UIColor clearColor];
        self.label.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.label];
        
        frame.origin.y = 0;
        frame.size.height /= 2;
        self.dayLabel = [[UILabel alloc] initWithFrame:frame];
        self.dayLabel.text = @"Oh yeah.";
        self.dayLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0];
        self.dayLabel.backgroundColor = [UIColor clearColor];
        self.dayLabel.textAlignment = NSTextAlignmentCenter;
        self.dayLabel.textColor = [UIColor grayColor];
        [self.contentView addSubview:self.dayLabel];
    }
    return self;
}

-(void)setProgress:(CGFloat)progress;
{
    CGFloat ab = fabs(progress);
    CGFloat pos = 1 - ab;
    self.contentView.alpha = pos * 0.65 + 0.35;
    
    CGFloat scale = pos * 1.35;
    if (scale > 1)
        scale = 1;
    scale = scale * .3 + .7;
    CGAffineTransform trans = CGAffineTransformIdentity;
    
    trans = CGAffineTransformScale(CGAffineTransformIdentity, scale, scale);
    trans = CGAffineTransformTranslate(trans, 0, ab * (7));
    
    self.contentView.transform = trans;
}

-(void)setDateValue:(int)value
{
    static NSDateFormatter *formatter = nil, *dayFormatter = nil;
    if (!formatter)
    {
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateStyle = NSDateFormatterMediumStyle;
        dayFormatter = [[NSDateFormatter alloc] init];
        dayFormatter.dateFormat = @"EEEE";
    }
    
    self.date = dateFromIndex(value);
    self.label.text = [formatter stringFromDate:self.date];
    self.dayLabel.text = [dayFormatter stringFromDate:self.date];
}

@end

@interface DQDateSlider ()<UICollectionViewDataSource, UICollectionViewDelegate>
{
    NSDate *_date;
    int _dateIndex;
}
@property UILabel *dateLabel;
@property UICollectionView *container;
@property UITapGestureRecognizer *doubleTap;
@end

@implementation DQDateSlider

- (id)init
{
    self = [super init];
    if (self) {
        [self setupView];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self setupView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

-(void)setupView
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    self.container = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    self.container.dataSource = self;
    self.container.delegate = self;
    self.container.backgroundColor = [UIColor clearColor];
    self.container.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.container.showsHorizontalScrollIndicator = self.container.showsVerticalScrollIndicator = NO;
    [self.container registerClass:[DQDateSliderCell class] forCellWithReuseIdentifier:[DQDateSliderCell reuseIdentifier]];
    [self addSubview:self.container];
    
    self.doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didDoubleTaps:)];
    self.doubleTap.numberOfTapsRequired = 2;
    [self.container addGestureRecognizer:self.doubleTap];
    
    self.frame = self.frame;
    self.date = [NSDate date];
    [self.container reloadData];
//    [self performSelector:@selector(refreshCellProgresses) withObject:nil afterDelay:.01];
}

-(void)setDate:(NSDate *)date animated:(BOOL)animated
{
    int index = indexFromDate(date);
    _dateIndex = index;
    NSIndexPath *path = [NSIndexPath indexPathForItem:index inSection:0];
    [self.container scrollToItemAtIndexPath:path atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    _date = date;
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    CGSize cellSize = frame.size;
    cellSize.width /= 2.0;
    UICollectionViewFlowLayout *layout = (id)self.container.collectionViewLayout;
    layout.itemSize = cellSize;

    self.container.frame = self.bounds;
}

-(void)didDoubleTaps:(UITapGestureRecognizer *)sender
{
    [self setDate:[NSDate date] animated:YES];
}

-(void)refreshCellProgresses
{
    CGFloat myCenter = self.bounds.size.width / 2;
    id paths = self.container.indexPathsForVisibleItems;
    for (NSIndexPath *indexPath in paths)
    {
        DQDateSliderCell *cell = (id)[self.container cellForItemAtIndexPath:indexPath];
        CGFloat center = (cell.frame.origin.x + cell.frame.size.width/2 - self.container.contentOffset.x);
        CGFloat progress = (center - myCenter) / myCenter;
        [cell setProgress:progress];
    }
}

#pragma mark - Properties

-(NSDate *)date
{
    return _date;
}
-(void)setDate:(NSDate *)date
{
    [self setDate:date animated:NO];
}

#pragma mark - UIScrollView

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self refreshCellProgresses];
}

-(CGFloat)roundValue:(CGFloat)value toNearestMultipleOf:(CGFloat)mod
{
    CGFloat down = mod * (int)(value / mod);
    CGFloat residue = value - down;
    if (residue > mod / 2.0)
        return down + mod;
    return down;
}

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    CGFloat x = targetContentOffset->x;
    CGFloat diff = self.frame.size.width / 4;
    x -= diff;
    x = [self roundValue:x toNearestMultipleOf:self.frame.size.width / 2];
    x += diff;
    targetContentOffset->x = x;
    
    
    NSIndexPath *ipForTargetRow = [self.container indexPathForItemAtPoint:*targetContentOffset];
    NSDate *targetDate = dateFromIndex(ipForTargetRow.row);
    NSLog(@"%@", targetDate);
}

#pragma mark - UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 25000; // Good 'til 2038.
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DQDateSliderCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[DQDateSliderCell reuseIdentifier] forIndexPath:indexPath];
    [cell setDateValue:indexPath.row];
    
    // This is a fix for a bug that I'm not exactly sure how to address.
    // When the VC containing this view first appears, the dates shown to
    // the left and right are shown at the same size as the date in the
    // center. So we're going to also set the progress in this method.
    if (indexPath.row > _dateIndex)
        [cell setProgress:1.0];
    else if (indexPath.row < _dateIndex)
        [cell setProgress:(-1.0)];
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    DQDateSliderCell *cell = (id)[collectionView cellForItemAtIndexPath:indexPath];
    [self setDate:cell.date animated:YES];

    self.container.userInteractionEnabled = NO;
    [self.container performSelector:@selector(setUserInteractionEnabled:) withObject:@(YES) afterDelay:.25];
}

@end
