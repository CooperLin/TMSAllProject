//
//  SlideViewController.m
//  i84Taoyuan
//
//  Created by TMS_APPLE on 2014/9/3.
//  Copyright (c) 2014年 TMS. All rights reserved.
//

#import "SlideViewController.h"
#import "AppDelegate.h"
#import "SearchBusViewController.h"
#import "nearStopViewController.h"
#import "FavoriteViewController.h"
#import "NotificationViewController.h"
#import "RoutePlanViewController.h"
#import "AboutViewController.h"
#import "SearchBusViewController2.h"

//http://tourguide.tainan.gov.tw/NewTNBusAPI/API/ClickCount.ashx?index=%E5%85%AC%E8%BB%8A%E5%8B%95%E6%85%8B&type=app
#define APIStatistic @"%@/NewAPI/API/ClickCount.ashx?index=%@&type=app"
//typedef enum _ButtonAdditionType
//{
//    ButtonAdditionTypeList
//    ,ButtonAdditionTypeMap
//    ,ButtonAdditionTypeEdit
//    ,ButtonAdditionTypeFavoriteOK
//    
//}ButtonAdditionType;
@interface SlideViewController ()
<
UINavigationControllerDelegate
>
@property BOOL isClickFirstPage;

@property (strong, nonatomic) IBOutlet UIView *viewMenuBack;
@property (strong, nonatomic) IBOutlet UIButton *buttonSlide;
@property (strong, nonatomic) IBOutlet UIView *viewHeader;
@property (strong, nonatomic) IBOutlet UIView *viewSlideBar;
@property (strong, nonatomic) IBOutlet UIView *viewBase;
@property (strong, nonatomic) IBOutlet UIButton *buttonAdditional;

@property (strong, nonatomic) IBOutlet UIButton *buttonSlideStatus;
@property (strong, nonatomic) SearchBusViewController * viewControllerSearchBus;
@property (strong, nonatomic) nearStopViewController * viewControllerNearStop;
@property (strong, nonatomic) FavoriteViewController * viewControllerFavorite;
@property (strong, nonatomic) NotificationViewController * viewControllerNotification;
@property (strong, nonatomic) RoutePlanViewController * viewControllerRoutePlan;
@property (strong, nonatomic) AboutViewController * viewControllerAbout;
@property (strong, nonatomic) SearchBusViewController2 * viewControllerSearchBus2;


@end

@implementation SlideViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isClickFirstPage = YES;
    // Do any additional setup after loading the view from its nib.
//    [self actSetDefault];
//    [self actSetIcons];
//    [appDelegate.kvoManager registerKvoWithInstance:appDelegate andAttributionName:@"function"];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self actSetSlide];
//    [self changeFunction:appDelegate.functionType];
    [self actButtonSlideTouchUpInside:nil];
}
//左滑到畫面外
-(void)actSetSlide
{
        //設定Back按鈕要不要顯示(依delegate有無傳回值)
        if (self.UIControl && [self.UIControl respondsToSelector:@selector(slideViewController:didTappedBackButton:)])
        {
            [self.viewMenuBack setHidden:NO];
        }
        else
        {
            [self.viewMenuBack setHidden:YES];
        }
}
-(void)viewWillDisappear:(BOOL)animated
{
    //離開view後讓menu隱藏
    [self actButtonSlideTouchUpInside:nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)actButtonFuctionTouchUpInside:(UIButton*)sender
{
    [self actButtonSlideTouchUpInside:nil];
    [self changeFunction:(SlideFunctionType)sender.tag];
}
-(void)changeViewController:(id)viewController
{
    if (![self.childViewControllers containsObject:viewController])
    {
        //有別的ChildViewController 跟Subview都移掉
        if (self.childViewControllers.count > 0)
        {
            for (id viewController in self.childViewControllers)
            {
                [((UIViewController*)viewController).view removeFromSuperview];
                [viewController removeFromParentViewController];
            }
        }
        [self addChildViewController:viewController];
        ((UIViewController*)viewController).view.frame = self.viewBody.bounds;
        [self.viewBody addSubview:((UIViewController*)viewController).view];
        
        for (id viewController in self.childViewControllers)
        {
            NSLog(@"\nviewController subViewControllers:\n%@",viewController);
        }
    }

}
- (IBAction)actButtonSlideTouchUpInside:(UIButton*)sender
{
    //移動SlideBar
    if (sender == nil || self.viewSlideBar.frame.origin.x == 0)
    {
        [self.buttonSlideStatus setSelected:NO];
        
        [UIView transitionWithView:self.view
                          duration:0.3
                           options:UIViewAnimationOptionCurveEaseInOut
                        animations:^{
                            CGRect frameNew = self.viewSlideBar.frame;
                            frameNew.origin.x = -self.viewSlideBar.frame.size.width;
                            self.viewSlideBar.frame = frameNew;

                        } completion:^(BOOL finished){
                            if (finished) {
                                /*
                                 edit Cooper 2015/08/17
                                 buglist0807 桃園第三項
                                 在xib 裡拉一個view 並讓其擋住使用者按後方的東西
                                 */
                                [self.viewCover setHidden:YES];
                            }
                            
                        }];
    }
    else
    {
        [self actSetSlide];
        [self.buttonSlideStatus setSelected:YES];
        [UIView transitionWithView:self.view
                          duration:0.3
                           options:UIViewAnimationOptionCurveEaseInOut
                        animations:^{
                            CGRect frameNew = self.viewSlideBar.frame;
                            frameNew.origin.x = 0;
                            self.viewSlideBar.frame = frameNew;
                        } completion:^(BOOL finished){
                            if (finished) {
                                /*
                                 edit Cooper 2015/08/17
                                 buglist0807 桃園第三項
                                 在xib 裡拉一個view 並讓其擋住使用者按後方的東西
                                 */
                                [self.viewCover setHidden:NO];
                            }
                            
                        }];
    }
}

- (IBAction)actButtonAdditionalTouchUpInside:(UIButton*)sender
{
    if (self.UIControl && [self.UIControl respondsToSelector:@selector(slideViewController:didTappedAdditionalButton:)])
    {
        [self.UIControl slideViewController:self didTappedAdditionalButton:self.buttonAdditional];
    }
}

-(void)changeFunction:(SlideFunctionType)type
{
    UIViewController * viewControllerSelected;
    NSString * stringTitle;
    switch (type)
    {
        case SlideFunctionTypeSearchBus:
        {
//            stringTitle = @"動態公車";
//            if (!self.viewControllerSearchBus)
//            {
//                self.viewControllerSearchBus = [[SearchBusViewController alloc]initWithNibName:@"SearchBusViewController" bundle:nil];
//            }
//            viewControllerSelected = self.viewControllerSearchBus;
            if(!self.viewControllerSearchBus2)
            {
                self.viewControllerSearchBus2 = [[SearchBusViewController2 alloc]initWithNibName:@"SearchBusViewController2" bundle:nil];
            }
            viewControllerSelected = self.viewControllerSearchBus2;

        }
            break;
        case SlideFunctionTypeRouthPlan:
        {
            stringTitle = @"路線規劃";
            if (!self.viewControllerRoutePlan)
            {
                self.viewControllerRoutePlan = [[RoutePlanViewController alloc]initWithNibName:@"RoutePlanViewController" bundle:nil];
            }
            [self.viewControllerRoutePlan clearPlanData];
            viewControllerSelected = self.viewControllerRoutePlan;
        }
            break;
        case SlideFunctionTypeNearStop:
        {
            stringTitle = @"附近站牌";
            if (!self.viewControllerNearStop)
            {
                self.viewControllerNearStop = [[nearStopViewController alloc] initWithNibName:@"nearStopViewController" bundle:nil];
            }
            viewControllerSelected = self.viewControllerNearStop;
        }
            break;
        case SlideFunctionTypeFavorite:
        {
            stringTitle = @"我的最愛";
            if (!self.viewControllerFavorite)
            {
                self.viewControllerFavorite = [[FavoriteViewController alloc]initWithNibName:@"FavoriteViewController" bundle:nil];
            }
            viewControllerSelected = self.viewControllerFavorite;
        }
            break;
            
        case SlideFunctionTypeNotification:
        {
            stringTitle = @"到站提醒";
            if (!self.viewControllerNotification)
            {
                self.viewControllerNotification = [[NotificationViewController alloc]initWithNibName:@"NotificationViewController" bundle:nil];
            }
            viewControllerSelected = self.viewControllerNotification;
        }
            break;
        case SlideFunctionTypeAbout:
        {
            stringTitle = @"關於";
            if (!self.viewControllerAbout)
            {
                self.viewControllerAbout = [[AboutViewController alloc]initWithNibName:@"AboutViewController" bundle:nil];
            }
            viewControllerSelected = self.viewControllerAbout;
        }
            break;
        case SlideFunctionTypeHome:
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(slideViewControllerBackToHome)])
            {
                [self.delegate slideViewControllerBackToHome];
            }
        }
            break;
        case SlideFunctionTypeBack:
        {
            if (self.UIControl && [self.UIControl respondsToSelector:@selector(slideViewController:didTappedBackButton:)])
            {
                [self.UIControl slideViewController:self didTappedBackButton:self.buttonAdditional];
            }
        }
            break;
            
        default:
            break;
    }
    if (stringTitle)
    {
//        self.labelTitle.text = stringTitle;
        NSString * stringUrl = [NSString stringWithFormat:APIStatistic,APIServer,stringTitle];
        [appDelegate.requestManager addRequestWithKey:@"Statistic" andUrl:stringUrl byType:RequestDataTypeString];
    }
    
    if (viewControllerSelected)
    {
        UINavigationController * navigatonController;
        if(self.isClickFirstPage){
            navigatonController = [[UINavigationController alloc]initWithRootViewController:viewControllerSelected];
            [navigatonController.navigationBar setHidden:YES];
        } else {
            if (!viewControllerSelected.navigationController)
            {
                navigatonController = [[UINavigationController alloc]initWithRootViewController:viewControllerSelected];
                [navigatonController.navigationBar setHidden:YES];
            }
            else
            {
                navigatonController = viewControllerSelected.navigationController;
            }
        }
        navigatonController.delegate = self;
        [self changeViewController:navigatonController];
    }

    if(!viewControllerSelected) {
        self.isClickFirstPage = YES;
    } else {
        self.isClickFirstPage = NO;
    }
    
}
-(void)actSetButtonAdditional
{
    if (self.UIControl && [self.UIControl respondsToSelector:@selector(slideViewController:setAdditionalButton:)])
    {
        [self.UIControl slideViewController:self setAdditionalButton:self.buttonAdditional];
        [self.buttonAdditional setHidden:NO];
    }
    else
    {
        [self.buttonAdditional setHidden:YES];
    }
}
-(void)actSetTitle
{
    if (self.UIControl && [self.UIControl respondsToSelector:@selector(slideViewController:setTitleLabel:)])
    {
        [self.UIControl slideViewController:self setTitleLabel:self.labelTitle];
    }
}
-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [self actSetButtonAdditional];
    [self actSetTitle];
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self actButtonFuctionTouchUpInside:nil];
}
@end
