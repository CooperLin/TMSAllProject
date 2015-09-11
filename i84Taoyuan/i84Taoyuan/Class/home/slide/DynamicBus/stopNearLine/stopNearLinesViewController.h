//
//  stopNearLinesViewController.h
//  i84Taoyuan
//
//  Created by TMS_APPLE on 2014/9/1.
//  Copyright (c) 2014年 ＴＭＳ 景翊科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface stopNearLinesViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UIView *ContentV;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UITableView *tableViewRoutes;
@property (strong, nonatomic) IBOutlet UILabel *labelUpdateTime;
@property (strong, nonatomic) NSDictionary * selectedStop;
- (IBAction)actBtnUpdateTouchUpInside:(id)sender;

@end
