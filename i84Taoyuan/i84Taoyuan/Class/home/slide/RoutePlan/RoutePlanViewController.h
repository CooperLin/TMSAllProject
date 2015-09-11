//
//  RoutePlanViewController.h
//  i84Taoyuan
//
//  Created by TMS_APPLE on 2014/8/21.
//  Copyright (c) 2014年 TMS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RoutePlanViewController : UIViewController

- (void)clearPlanData;
-(NSString *)actPointToAddressLat:(float)lat actPointToAddressLon:(float)lon;

@end
