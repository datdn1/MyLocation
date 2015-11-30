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
    NSError *_lastLocationError;
    BOOL _updatingLocation;
    
    CLGeocoder *_geocoder;
    CLPlacemark *_placemark;
    BOOL _performingReverseGeocoding;
    NSError *_geocodingError;
}
// create location manager when load from storyboard
-(instancetype) initWithCoder:(NSCoder *)aDecoder {
    if(self = [super initWithCoder:aDecoder]) {
        _coreLocationManager = [[CLLocationManager alloc] init];
        
        _geocoder = [[CLGeocoder alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateLocationLabel];
    [self configureGetLocationButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// implement delegate of core location to get current location
// turn on GPS when need fix location
- (IBAction)getLocation:(id)sender {
    if (!_updatingLocation) {
        // start location service
        _currentLocation = nil;
        _lastLocationError = nil;
        
        _placemark = nil;
        _geocodingError = nil;
        
        [self startLocationManager];
    }
    else {
        [self stopLocationManager];
    }
    
    [self updateLocationLabel];
    [self configureGetLocationButton];
}

#pragma mark - CoreLocation delegates
-(void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError: %@", error);
    
    // if location unknown then trying
    if (error.code == kCLErrorLocationUnknown) {
        return;
    }
    
    // stop location manager when has other error
    [self stopLocationManager];
    
    // set error varible for update
    _lastLocationError = error;
    
    // reset current location
//    _currentLocation = nil;
    
    // view error for user
    [self updateLocationLabel];
    
    [self configureGetLocationButton];
}

-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *newLocation = [locations lastObject];
    NSLog(@"New location: %@", newLocation);
    
    if ([newLocation.timestamp timeIntervalSinceNow] < -5.0) {
        return;
    }
    
    if (newLocation.horizontalAccuracy < 0) {
        return;
    }
    
    if (_currentLocation == nil || _currentLocation.horizontalAccuracy > newLocation.horizontalAccuracy) {
        _currentLocation = newLocation;
        
        // reset error variable
        _lastLocationError = nil;
        
        [self updateLocationLabel];
        
        if (_currentLocation.horizontalAccuracy <= _coreLocationManager.desiredAccuracy) {
            NSLog(@"Stop location service");
            [self stopLocationManager];
            
            [self configureGetLocationButton];
            
            if (!_performingReverseGeocoding) {
                NSLog(@"*** Going to geocoding ***");
                
                _performingReverseGeocoding = YES;
                [self updateLocationLabel];
                
                [_geocoder reverseGeocodeLocation:_currentLocation completionHandler:^(NSArray<CLPlacemark *> *placemarks, NSError *error) {
                    NSLog(@"*** Found placemark: %@ error: %@", placemarks, error);
                    _geocodingError = error;
                    if (error == nil && placemarks.count > 0) {
                        _placemark = [placemarks lastObject];
                    }
                    else {
                        _placemark = nil;
                    }
                    _performingReverseGeocoding = NO;
                    [self updateLocationLabel];
                }];
            }

        }
    }
    
}

-(void) updateLocationLabel {
    if (_currentLocation != nil) {
        self.longLabel.text = [NSString stringWithFormat:@"%.8f", _currentLocation.coordinate.longitude];
        self.latLabel.text = [NSString stringWithFormat:@"%.8f", _currentLocation.coordinate.latitude];
        self.tagLocationButton.hidden = NO;
//        self.messageLabel.text = @"";
        
        if (_placemark != nil) {
            self.addressLabel.text = [self stringFromPlacemark:_placemark];
        }
        else if (_geocodingError != nil) {
            self.addressLabel.text = @"Error Finding Address";
        }
        else if (_performingReverseGeocoding) {
            self.addressLabel.text = @"Searching for Address...";
        }
        else {
            self.addressLabel.text = @"No Address Found";
        }
    }
    else {
        self.latLabel.text = @"";
        self.longLabel.text = @"";
        self.addressLabel.text = @"";
        self.tagLocationButton.hidden = YES;
        NSString *statusMessage;
        
        // error case
        if (_lastLocationError != nil) {
            // user dined location service
            if ([_lastLocationError.domain isEqualToString:kCLErrorDomain] && _lastLocationError.code == kCLErrorDenied) {
                statusMessage = @"Location Services Disabled";
            }
            // error when search location from core location
            else {
                statusMessage = @"Error Getting Location";
            }
        }
        // location service global disable case
        else if (![CLLocationManager locationServicesEnabled]) {
            statusMessage = @"Location Services Disabled";
        }
        
        // searching case
        else if (_updatingLocation) {
            statusMessage = @"Searching...";
        }
        else {
            statusMessage = @"Press the button to start";
        }
        self.messageLabel.text = statusMessage;
    }
}

-(void) startLocationManager {
    _coreLocationManager.delegate = self;
    _coreLocationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    
    // enable core location by code
    [_coreLocationManager requestWhenInUseAuthorization];
    [_coreLocationManager requestAlwaysAuthorization];
    
    // set updating location flag
    _updatingLocation = YES;
    
    [_coreLocationManager startUpdatingLocation];
}

-(void) stopLocationManager {
    if (_updatingLocation) {
        [_coreLocationManager stopUpdatingLocation];
        _coreLocationManager.delegate = nil;
        _updatingLocation = NO;
    }
}

-(void) configureGetLocationButton {
    if (_updatingLocation) {
        [self.getMyLocationButton setTitle:@"Stop" forState:UIControlStateNormal];
        
    }
    else {
        [self.getMyLocationButton setTitle:@"Get My Location" forState:UIControlStateNormal];
    }
}

-(NSString *) stringFromPlacemark:(CLPlacemark *)placemark {
    return [NSString stringWithFormat:@"%@ %@\n%@ %@ %@", placemark.subThoroughfare, placemark.thoroughfare, placemark.locality, placemark.administrativeArea, placemark.postalCode];
}


@end
