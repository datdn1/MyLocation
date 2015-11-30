//
//  CurrentLocationViewController.h
//  MyLocation
//
//  Created by datdn1 on 11/30/15.
//  Copyright © 2015 datdn1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CurrentLocationViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *longLabel;
@property (weak, nonatomic) IBOutlet UILabel *latLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIButton *tagLocationButton;
@property (weak, nonatomic) IBOutlet UIButton *getMyLocationButton;
@end
