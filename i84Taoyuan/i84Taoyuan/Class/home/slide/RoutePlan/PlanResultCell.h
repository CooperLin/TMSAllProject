//
//  PlanResultCell.h
//  i84-TaichungV2
//
//  Created by ＴＭＳ 景翊科技 on 2014/3/11.
//  Copyright (c) 2014年 ＴＭＳ 景翊科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlanResultCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel * labelPlan;
@property (strong, nonatomic) IBOutlet UILabel * labelTravelTime;
@property (strong, nonatomic) IBOutlet UILabel * labelRoute;
@property (strong, nonatomic) IBOutlet UILabel * labelDescription;
@property (strong, nonatomic) IBOutlet UILabel * labelArriveTime;
@property (strong, nonatomic) IBOutlet UIImageView * imageViewTitleBackground;

//////////////////////////////
@property (weak, nonatomic) IBOutlet UIView *viewPlanSubView;
@property (weak, nonatomic) IBOutlet UIView *viewPlanNum3;
@property (weak, nonatomic) IBOutlet UIImageView *imgPlanStart3;
@property (weak, nonatomic) IBOutlet UIImageView *imgPlanChange3;
@property (weak, nonatomic) IBOutlet UIImageView *imgPlanEnd3;
@property (weak, nonatomic) IBOutlet UILabel *labelPlanChange3;
@property (weak, nonatomic) IBOutlet UILabel *labelArrow3_1;
@property (weak, nonatomic) IBOutlet UILabel *labelArrow3_2;

//////////////////////////////
@property (weak, nonatomic) IBOutlet UIView *viewPlanNum5;
@property (weak, nonatomic) IBOutlet UIImageView *imgPlanChange5_1;
@property (weak, nonatomic) IBOutlet UIImageView *imgPlanChange5_2;
@property (weak, nonatomic) IBOutlet UIImageView *imgPlanChange5_3;
@property (weak, nonatomic) IBOutlet UIImageView *imgPlanStart5;
@property (weak, nonatomic) IBOutlet UIImageView *imgPlanEnd5;
@property (weak, nonatomic) IBOutlet UILabel *labelPlanChange5_1;
@property (weak, nonatomic) IBOutlet UILabel *labelPlanChange5_2;



@end
