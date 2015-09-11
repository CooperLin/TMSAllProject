//
//  NearStopCell.h
//  i84Taoyuan
//
//  Created by TMS_APPLE on 2014/9/1.
//  Copyright (c) 2014年 ＴＭＳ 景翊科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NearStopCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *labelRouteName;
@property (strong, nonatomic) IBOutlet UILabel *labelRouteToward;
@property (strong, nonatomic) IBOutlet UILabel *labelRouteArriveTime;
@property (strong, nonatomic) IBOutlet UILabel *labelStopName;
@property (weak, nonatomic) IBOutlet UILabel *labelSerialNumber;

@end
