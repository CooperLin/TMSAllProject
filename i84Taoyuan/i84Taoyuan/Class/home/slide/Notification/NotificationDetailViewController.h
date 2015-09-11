//
//  NotificationDetailViewController.h
//  i84Taoyuan
//
//  Created by TMS_APPLE on 2014/8/15.
//  Copyright (c) 2014年 TMS. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    NotificationUpdateTypeAdd = 1
    ,NotificationUpdateTypeUpdate = 2
    ,NotificationUpdateTypeDelete = 3
}NotificationUpdateType;

@interface NotificationDetailViewController : UIViewController
@property (strong, nonatomic) NSMutableDictionary *selectedStop;

+(NSString*)urlStringFromDictionary:(NSDictionary*)stop byType:(NotificationUpdateType)type;

@end
