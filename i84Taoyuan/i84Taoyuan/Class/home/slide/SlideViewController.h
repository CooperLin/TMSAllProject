//
//  SlideViewController.h
//  i84Taoyuan
//
//  Created by TMS_APPLE on 2014/9/3.
//  Copyright (c) 2014年 TMS. All rights reserved.
//

#import <UIKit/UIKit.h>


//需在XIB SlideViewController跟HomeViewController Button.tag設定對應的數字
typedef enum _SlideFunctionType
{
    SlideFunctionTypeSearchBus = 1
    ,SlideFunctionTypeRouthPlan = 2
    ,SlideFunctionTypeFavorite = 3
    ,SlideFunctionTypeNearStop = 4
    ,SlideFunctionTypeNotification = 5
    ,SlideFunctionTypeAbout = 6
    ,SlideFunctionTypePlay = 8
    ,SlideFunctionTypeBusDynamic = 11
    ,SlideFunctionTypeLinesPassByStop = 111
    ,SlideFunctionTypeRouteTime = 112
    ,SlideFunctionTypeHome = -1
    ,SlideFunctionTypeBack = -2

}SlideFunctionType;

@protocol SlideViewControllerDelegate <NSObject>
@optional
-(void)slideViewControllerBackToHome;

@required
@end
@protocol SlideViewControllerUIControl <NSObject>
@optional
-(void)slideViewController:(id)viewController setAdditionalButton:(UIButton*)button;
-(void)slideViewController:(id)viewController didTappedAdditionalButton:(UIButton*)button;
-(void)slideViewController:(id)viewController setTitleLabel:(UILabel*)label;
//傳回Back連結的ViewController,若此delegate未設定則隱藏按鈕
-(void)slideViewController:(id)viewController didTappedBackButton:(UIButton*)button;
//右方按鍵
@required
@end

@interface SlideViewController : UIViewController
@property (strong,nonatomic)id<SlideViewControllerDelegate>delegate;
@property (strong,nonatomic)id<SlideViewControllerUIControl>UIControl;
@property (assign,nonatomic) SlideFunctionType functionType;
@property (strong,nonatomic) NSString *function;
@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
-(void)changeFunction:(SlideFunctionType)type;
@property (strong, nonatomic) IBOutlet UIView *viewBody;
/*
 edit Cooper 2015/08/17
 buglist0807 桃園第三項
 在xib 裡拉一個view 並讓其擋住使用者按後方的東西
 */
@property (strong, nonatomic) IBOutlet UIView *viewCover;

@end
