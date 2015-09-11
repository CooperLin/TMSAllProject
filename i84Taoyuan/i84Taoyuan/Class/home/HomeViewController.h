//
//  HomeViewController.h
//  i84Taoyuan
//
//  Created by TMS_APPLE on 2014/9/2.
//  Copyright (c) 2014年 TMS. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HomeViewControllerDelegate <NSObject>
@optional
-(void)homeViewController:(id)viewController goToFunction:(int)type;
@required
@end
@interface HomeViewController : UIViewController
@property (strong,nonatomic) id<HomeViewControllerDelegate>delegate;
@end

