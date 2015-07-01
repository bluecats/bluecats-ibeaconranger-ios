//
//  ViewController.m
//  iBeaconRanger
//
//  Created by BlueCats Austin on 7/1/15.
//  Copyright (c) 2015 BlueCats. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/Corelocation.h>

@interface ViewController () <CLLocationManagerDelegate>

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) CLBeaconRegion *iBeaconRangerRegion;

@end

@implementation ViewController

- (CLBeaconRegion *)iBeaconRangerRegion
{
    
    if (!_iBeaconRangerRegion) {
        
        _iBeaconRangerRegion = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString: @"YOUR PROXIMITY UUID GOES HERE"] identifier:@"com.blueCats.iBeaconRangerRegion"];
    
        _iBeaconRangerRegion.notifyOnEntry = YES;
        _iBeaconRangerRegion.notifyOnExit = YES;
        _iBeaconRangerRegion.notifyEntryStateOnDisplay = YES;
    }
    return _iBeaconRangerRegion;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    if (CLLocationManager.authorizationStatus == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestAlwaysAuthorization];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Private methods

- (NSString *)stringForRegionState:(CLRegionState)state
{
    NSString *string = nil;
    switch (state) {
        case CLRegionStateInside:
            string = @"Inside";
            break;
        case CLRegionStateOutside:
            string = @"Outside";
            break;
        case CLRegionStateUnknown:
        default:
            string = @"Unknown";
            break;
    }
    return string;
}

- (NSString *)stringForAuthorizationStatus:(CLAuthorizationStatus)status
{
    NSString *string = nil;
    switch (status) {
        case kCLAuthorizationStatusAuthorizedAlways:
            string = @"Always";
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            string = @"WhenInUse";
            break;
        case kCLAuthorizationStatusRestricted:
            string = @"Restricted";
            break;
        case kCLAuthorizationStatusNotDetermined:
            string = @"NotDetermined";
            break;
        case kCLAuthorizationStatusDenied:
            string = @"Denied";
            break;
        default:
            string = @"Unknown";
            break;
    }
    return string;
}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    NSLog(@"Did change authorization status %@", [self stringForAuthorizationStatus:status]);
    
    if (CLLocationManager.authorizationStatus == kCLAuthorizationStatusAuthorizedAlways) {
        
        for (CLRegion *region in self.locationManager.monitoredRegions) {
            if ([region isKindOfClass:[CLBeaconRegion class]]) {
                [self.locationManager stopRangingBeaconsInRegion:(CLBeaconRegion *)region];
            }
            [self.locationManager stopMonitoringForRegion:region];
        }
        [self.locationManager startMonitoringForRegion:self.iBeaconRangerRegion];
        [self.locationManager startRangingBeaconsInRegion:self.iBeaconRangerRegion];
        [self.locationManager requestStateForRegion:self.iBeaconRangerRegion];
    }
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    NSLog(@"Monitoring did fail for region %@ with error %@", region.identifier, [error localizedDescription]);
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    NSLog(@"Did enter region with identifier %@", region.identifier);
    
    [self.locationManager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    NSLog(@"Did exit region with identifier %@", region.identifier);
    
    [self.locationManager stopRangingBeaconsInRegion:(CLBeaconRegion *)region];
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    NSLog(@"Did start monitoring for region with identifier %@", region.identifier);
}

- (void) locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    NSLog(@"Determined state %@ for region with identifier %@", [self stringForRegionState:state], region.identifier);
    
    switch (state) {
        case CLRegionStateInside:
            [self.locationManager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
            break;
        case CLRegionStateOutside:
            [self.locationManager stopRangingBeaconsInRegion:(CLBeaconRegion *)region];
            break;
        case CLRegionStateUnknown:
        default:
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    NSLog(@"Did range %lu beacons in region with identifier %@", (unsigned long)beacons.count, region.identifier);
    
    for (CLBeacon *beacon in beacons) {
        NSLog(@"%@:%ld:%ld rssi: %ld dBm", beacon.proximityUUID.UUIDString, (long)[beacon.major integerValue], (long)[beacon.minor integerValue], (long)beacon.rssi);
    }
}

- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error
{
    NSLog(@"Ranging beacons did fail for region %@ with error %@", region.identifier, [error localizedDescription]);
}

@end

