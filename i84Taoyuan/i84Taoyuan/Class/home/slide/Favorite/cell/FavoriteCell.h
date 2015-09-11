//
//  FavoriteCell.h
//  i84-TaichungV2
//
//  Created by ＴＭＳ 景翊科技 on 2014/3/4.
//  Copyright (c) 2014年 ＴＭＳ 景翊科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FavoriteCell : UITableViewCell

@property (nonatomic,strong) IBOutlet UIImageView * imageIcon;
@property (nonatomic,strong) IBOutlet UILabel * labelRouteName;
@property (nonatomic,strong) IBOutlet UILabel * labelStopName;
@property (nonatomic,strong) IBOutlet UILabel * labelToward;
@property (nonatomic,strong) IBOutlet UILabel * labelArriveTime;

@end
