//
//  MapSettingViewController.h
//  i84Taoyuan
//
//  Created by TMS_APPLE on 2014/9/24.
//  Copyright (c) 2014年 TMS. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum _MapSettingMenuMode
{
    MapSettingMenuModeBottonsWithoutHomeAndOffice = 1
    ,MapSettingMenuModeButtonsAll = 0
}
MapSettingMenuMode;
@protocol MapSettingViewControllerDelegate<NSObject>
@optional
-(void)mapSetting:(UIViewController*)viewController setLocation:(NSMutableDictionary*)location toStart:(BOOL)target;



@required
@end
@interface MapSettingViewController : UIViewController
@property (strong, nonatomic) id<MapSettingViewControllerDelegate>
delegate;
@property (assign, nonatomic) MapSettingMenuMode menuMode;

-(void)setMapMenu:(MapSettingMenuMode)mode;

@end
