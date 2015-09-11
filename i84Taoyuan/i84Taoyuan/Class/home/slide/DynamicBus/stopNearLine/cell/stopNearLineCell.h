//
//  stopNearLineCell.h
//  i84Taoyuan
//
//  Created by TMS_APPLE on 2014/9/1.
//  Copyright (c) 2014年 ＴＭＳ 景翊科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface stopNearLineCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *labelSerialNumber;
@property (strong, nonatomic) IBOutlet UILabel *labelRouteName;
@property (strong, nonatomic) IBOutlet UILabel *labelRouteToward;
@property (strong, nonatomic) IBOutlet UILabel *labelRouteArriveTime;
@property (strong, nonatomic) IBOutlet UIImageView *imageViewTimeBackground;
@property (weak, nonatomic) IBOutlet UIImageView *imageBusType;
@property (weak, nonatomic) IBOutlet UILabel *labelBusPlate;


@end
