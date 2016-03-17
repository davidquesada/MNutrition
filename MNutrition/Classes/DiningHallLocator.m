//
//  DiningHallLocator.m
//  MNutrition
//
//  Created by David Paul Quesada on 3/17/16.
//  Copyright © 2016 David Quesada. All rights reserved.
//

#import "DiningHallLocator.h"
#import <CoreLocation/CoreLocation.h>

@interface DiningHallLocator ()<CLLocationManagerDelegate>

@property CLLocationManager *locationManager;
@property NSMutableArray *callbacks;

@end

@implementation DiningHallLocator

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.delegate = self;
        
        self.callbacks = [[NSMutableArray alloc] init];
    }
    return self;
}

-(BOOL)canLocate
{
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted)
        return NO;
    return YES;
}

-(void)locate:(void (^)(MMDiningHall *))callback
{
#ifdef __IPHONE_8_0
    // New in iOS 8. You need to call this before using the locationManager, otherwise it fails silently.
    if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
        [_locationManager requestWhenInUseAuthorization];
#endif
    
    [_callbacks addObject:callback];
    
    [self.locationManager startUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate Methods

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"-[DiningHallLocator locationManager:didUpdateToLocation:fromLocation:]");
    
    [manager stopUpdatingLocation];
    
    if (!_callbacks.count)
        return;
    
    MMDiningHall *hall = [MMDiningHall diningHallClosestToLocation:newLocation];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        for (void (^cb)(MMDiningHall *) in _callbacks)
        {
            cb(hall);
        }
        [_callbacks removeAllObjects];
    });
}

@end
