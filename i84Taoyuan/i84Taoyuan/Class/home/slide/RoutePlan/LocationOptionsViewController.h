//
//  LocationOptionsViewController.h
//  i84Taoyuan
//
//  Created by TMS_APPLE on 2014/9/25.
//  Copyright (c) 2014年 TMS. All rights reserved.
//
//  Server接收
typedef enum
{
    LocationOptionsReturnTargetStart = 1
    ,LocationOptionsReturnTargetEnd = 2
}
LocationOptionsReturnTarget;

typedef enum
{
    LocationOptionsCollectionModeAdd = 1
    ,LocationOptionsCollectionModeDelete = 0
}
LocationOptionsCollectionMode;
#import "DataManager+Location.h"
#import <UIKit/UIKit.h>
@protocol LocationOptionsViewControllerDelegate<NSObject>
-(void)locationOptionsViewController:(UIViewController*)viewController withDictionary:(NSDictionary*)location andTarget:(LocationOptionsReturnTarget)target;
@end
@interface LocationOptionsViewController : UIViewController
@property (strong, nonatomic) NSMutableArray * arrayList;
@property (strong, nonatomic) id<LocationOptionsViewControllerDelegate>delegate;
@property (assign, nonatomic) BOOL collectionMode;
@end
