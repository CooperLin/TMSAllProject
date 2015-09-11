//
//  busDynamicViewController.h
//  i84Taoyuan
//
//  Created by TMS_APPLE on 2014/9/1.
//  Copyright (c) 2014年 ＴＭＳ 景翊科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideViewController.h"
//#import "PushViewer.h"
//#import "webViewController.h"
typedef enum _BusDynamicRequestType
{
    DynamicTime = 1,
} BusDynamicRequestType;

@interface busDynamicViewController : UIViewController
<
UITableViewDataSource
,UITableViewDelegate
,SlideViewControllerUIControl
>
@property (strong, nonatomic) IBOutlet UIView *ContentV;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UILabel *labelBusName;
@property (strong, nonatomic) IBOutlet UIButton *btnForward;
@property (strong, nonatomic) IBOutlet UIButton *btnBackward;
@property (strong, nonatomic) IBOutlet UITableView *tableViewMain;
@property (strong, nonatomic) IBOutlet UIView *viewCellSelectedMenu;
@property (strong, nonatomic) IBOutlet UILabel *labelUpdateTime;
@property (strong, nonatomic) NSDictionary * selectedRoute;

- (IBAction)actBtnTowardTouchUpInside:(id)sender;
- (IBAction)actBtnMenuTouchUpInside:(id)sender;
- (IBAction)actBtnUpdateTouchUpInside:(id)sender;

@end
