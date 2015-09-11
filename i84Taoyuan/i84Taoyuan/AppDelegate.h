//
//  AppDelegate.h
//  i84Taoyuan
//
//  Created by TMS_APPLE on 2014/9/1.
//  Copyright (c) 2014年 TMS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RequestManager.h"
#import "DataManager+Route.h"
#import "SlideViewController.h"
#import "HomeViewController.h"
#import "UpdateTimer.h"

#define IOSVersion ([[[UIDevice currentDevice]systemVersion]floatValue])

#define APIServer @"http://117.56.151.240/Taoyuan"
#define ValueUpdateTime 10
#define ValueRequestTimeout 30

#define appDelegate ((AppDelegate *)[[UIApplication sharedApplication]delegate])
#define userDefaults ([NSUserDefaults standardUserDefaults])

@interface AppDelegate : UIResponder <UIApplicationDelegate,SlideViewControllerDelegate,HomeViewControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) SlideViewController *viewControllerSlide;
@property (strong, nonatomic) HomeViewController *viewControllerHome;

@property (strong, nonatomic) RequestManager *requestManager;
@property (strong, nonatomic) UpdateTimer *updateTimer;
@property (strong, nonatomic) NSString * token;
//@property (strong, nonatomic) KVOManager *kvoManager;
//@property (assign, nonatomic) SlideFunctionType functionType;


@property (strong ,nonatomic) NSMutableArray * arrayIndustryRoutes;

- (void)showAlertView:(NSString *)title setMessage:(NSString *)message setMessage:(NSString *)cancel;

-(void)actGoToFunction:(SlideFunctionType)type;

@end


