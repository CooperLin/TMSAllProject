//
//  nearStopViewController.h
//  i84Taoyuan
//
//  Created by TMS_APPLE on 2014/9/1.
//  Copyright (c) 2014年 ＴＭＳ 景翊科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocationManagerDelegate.h>

@interface nearStopViewController : UIViewController
<
CLLocationManagerDelegate
,UITableViewDataSource
,UITableViewDelegate
>
@property (strong, nonatomic) IBOutlet UIView *ContentV;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UIView *viewDistanceButtons;
@property (strong, nonatomic) IBOutlet UITableView *tableViewMain;
@property (strong, nonatomic) IBOutlet UILabel *labelUpdateTime;
- (IBAction)actBtnDistanceTouchUpInside:(id)sender;
- (IBAction)actBtnUpdateTouchUpInside:(id)sender;

@end
