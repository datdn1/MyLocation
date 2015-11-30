//
//  CurrentLocationViewController.m
//  MyLocation
//
//  Created by datdn1 on 11/30/15.
//  Copyright © 2015 datdn1. All rights reserved.
//

#import "CurrentLocationViewController.h"
#import <CoreLocation/CoreLocation.h>


@interface CurrentLocationViewController () <CLLocationManagerDelegate>
@end

@implementation CurrentLocationViewController
{
    CLLocationManager *_coreLocationManager;
    CLLocation *_currentLocation;
}
// create location manager when load from storyboard
-(instancetype) initWithCoder:(NSCoder *)aDecoder {
    if(self = [super initWithCoder:aDecoder]) {
        _coreLocationManager = [[CLLocationManager alloc] init];
    }
    return self;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateLocationLabel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// implement delegate of core location to get current location
// turn on GPS when need fix location
- (IBAction)getLocation:(id)sender {
    _coreLocationManager.delegate = self;
    _coreLocationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    // enable core location by code
    [_coreLocationManager requestWhenInUseAuthorization];
    [_coreLocationManager requestAlwaysAuthorization];
    
    [_coreLocationManager startUpdatingLocation];
}

#pragma mark - CoreLocation delegates
-(void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError: %@", error);
}

-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *newLocation = [locations lastObject];
    NSLog(@"New location: %@", newLocation);
    _currentLocation = newLocation;
    [self updateLocationLabel];
}

-(void) updateLocationLabel {
    if (_currentLocation != nil) {
        self.longLabel.text = [NSString stringWithFormat:@"%.8f", _currentLocation.coordinate.longitude];
        self.latLabel.text = [NSString stringWithFormat:@"%.8f", _currentLocation.coordinate.latitude];
        self.tagLocationButton.hidden = NO;
        self.messageLabel.text = @"";
    }
    else {
        self.latLabel.text = @"";
        self.longLabel.text = @"";
        self.addressLabel.text = @"";
        self.tagLocationButton.hidden = YES;
        self.messageLabel.text = @"Press Get My Location to start";
    }
 
    
}


@end
