//
//  NotificationCell.h
//  i84-TaichungV2
//
//  Created by ＴＭＳ 景翊科技 on 2014/3/4.
//  Copyright (c) 2014年 ＴＭＳ 景翊科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *labelRouteName;
@property (strong, nonatomic) IBOutlet UILabel *labelStopName;
@property (strong, nonatomic) IBOutlet UILabel *labelToward;
@property (strong, nonatomic) IBOutlet UILabel *labelTime;
@property (strong, nonatomic) IBOutlet UILabel *labelWeek;
@property (strong, nonatomic) IBOutlet UIImageView *imageViewSwich;


@end
