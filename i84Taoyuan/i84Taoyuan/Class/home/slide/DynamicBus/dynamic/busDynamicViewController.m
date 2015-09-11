
//
//  busDynamicViewController.m
//  i84Taoyuan
//
//  Created by TMS_APPLE on 2014/9/1.
//  Copyright (c) 2014年 ＴＭＳ 景翊科技. All rights reserved.
//

#import "busDynamicViewController.h"

#import "AppDelegate.h"
#import "ShareTools.h"
#import "busDynamicCell.h"
#import "SlideViewController.h"
#import "RequestManager.h"
#import "UpdateTimer.h"
#import "stopNearLinesViewController.h"
#import "TimeListViewController.h"
#import "DataManager+Favorite.h"
#import "NotificationDetailViewController.h"

//http://117.56.151.240/Taoyuan/NewAPI/API/CrossRouteByPathId.ashx?id=119
#define APIRouteStops @"%@/NewAPI/API/CrossRouteByPathId.ashx?id=%@"

typedef enum
{
    DynamicMenuButtonTypeAddToFavorite = 1
    ,DynamicMenuButtonTypeLinesNearStop = 3
    ,DynamicMenuButtonTypeAddToNotification = 2
    
}
DynamicMenuButtonType;

@interface busDynamicViewController ()
<
SlideViewControllerUIControl
,RequestManagerDelegate
,UpdateTimerDelegate
>
{
    NSMutableArray * arrayTableviewStops;
    NSMutableDictionary * dictionaryForwardStops;
    NSMutableDictionary * dictionaryBackwardStops;
    
    NSMutableDictionary * LeftMenu_BackBtn;

    NSInteger intQueryFail;
    NSInteger integerUpdateTime;
    NSMutableDictionary * dictionarySelectedStop;
    
    UISwipeGestureRecognizer *swipeToLeft;
    UISwipeGestureRecognizer *swipeToRight;
    BOOL isOneWay;
    BOOL isOld;
}
@property (nonatomic, strong) TimeListViewController *viewControllerTimeList;
@property (nonatomic, strong) UIActionSheet * actionSheetTimeList;
@property (nonatomic, strong) stopNearLinesViewController *viewControllerStopNearLines;
@property (nonatomic, strong) NotificationDetailViewController * viewControllerNotificationDetail;

@end

@implementation busDynamicViewController

#pragma mark - Life Cycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    isOneWay = NO;
    [self actSetCellSeletedMenu];
}

-(void)viewWillAppear:(BOOL)animated
{
    appDelegate.updateTimer.delegate = self;
    appDelegate.requestManager.delegate = self;
    appDelegate.viewControllerSlide.UIControl = self;
    [self actSetView];
    [self actQueryData];
    [self actSwipe];
    [self actHideFunctionMenu];
}
-(void)viewWillDisappear:(BOOL)animated
{
    if (appDelegate.viewControllerSlide.UIControl == self)
    {
        appDelegate.viewControllerSlide.UIControl = nil;
    }
    if (appDelegate.requestManager.delegate == self)
    {
        appDelegate.requestManager.delegate = nil;
    }
    if (appDelegate.updateTimer.delegate == self)
    {
        appDelegate.updateTimer.delegate = nil;
    }
    [self actClearTableView];
}
-(void)actClearTableView
{
    [dictionaryForwardStops removeAllObjects];
    [dictionaryBackwardStops removeAllObjects];
    [self.tableViewMain reloadData];
}
-(void)actSetView
{
    //設定各Title
    NSString *str = self.selectedRoute[KeyRouteName];
    isOld = str.length;
    NSString *setStr = (isOld)?self.selectedRoute[KeyRouteName]:self.selectedRoute[@"nameZh"];
    [self.labelBusName setText:[self.selectedRoute objectForKey:setStr]];
    
    NSString *strForward = (isOld)?[self.selectedRoute objectForKey:KeyRouteDestination]:[self.selectedRoute objectForKey:@"destinationZh"];
    NSString * stringForward = [NSString stringWithFormat:@"往%@",strForward];
    
    NSString *strBackward = (isOld)?[self.selectedRoute objectForKey:KeyRouteDeparture]:[self.selectedRoute objectForKey:@"departureZh"];
    NSString * stringBackward = [NSString stringWithFormat:@"往%@",strBackward];
    
    self.btnForward.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.btnForward setTitle:stringForward forState:UIControlStateNormal];
    self.btnBackward.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.btnBackward setTitle:stringBackward forState:UIControlStateNormal];
    
    if ([self.btnForward isSelected])
    {
        [self.btnForward setSelected:NO];
        [self.btnForward setSelected:YES];
    }
    if ([self.btnBackward isSelected])
    {
        [self.btnBackward setSelected:NO];
        [self.btnBackward setSelected:YES];
    }
}
-(void)actSetCellSeletedMenu
{
    [self.ContentV addSubview:self.viewCellSelectedMenu];
    [self actHideFunctionMenu];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)actQueryData
{
    NSString *str = (isOld)?[self.selectedRoute objectForKey:KeyRouteID]:[self.selectedRoute objectForKey:@"ID"];
    NSString * stringUrl = [NSString stringWithFormat:APIRouteStops,APIServer,str];
    NSString * stringRoute = (isOld)?[self.selectedRoute objectForKey:KeyRouteID]:[self.selectedRoute objectForKey:@"nameZh"];
    NSLog(@"Key %@",stringRoute);
    [appDelegate.requestManager addRequestWithKey:stringRoute andUrl:stringUrl byType:RequestDataTypeJson];
}
#pragma mark - RequestManager Delegate
-(void)requestManagerStartActivityIndicator
{
    [self startActivityIndicator];
}
-(void)requestManagerStopActivityIndicator
{
    [self stopActivityIndicator];
}
-(void)requestManager:(id)requestManager returnJSONSerialization:(NSJSONSerialization *)jsonSerialization withKey:(NSString *)key
{
    if ([key isEqualToString:[self.selectedRoute objectForKey:KeyRouteID]])
    {
        NSArray * arrayFronJson = (NSArray*)jsonSerialization;
        [self actSeparateArrayByTowards:arrayFronJson];
        integerUpdateTime = 1;
    }
}
-(void)requestManager:(id)requestManager returnString:(NSString *)stringResponse withKey:(NSString *)key
{
    if ([key isEqualToString:@"NotificationAdd"])
    {
        if ([stringResponse isEqualToString:@"1"]||[stringResponse isEqualToString:@"ok"])
        {
            if (!self.viewControllerNotificationDetail)
            {
                self.viewControllerNotificationDetail = [[NotificationDetailViewController alloc]initWithNibName:@"NotificationDetailViewController" bundle:nil];
            }
            self.viewControllerNotificationDetail.selectedStop = dictionarySelectedStop;
            
            [self.navigationController pushViewController:self.viewControllerNotificationDetail animated:YES];
        }
        else
        {
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"加入失敗" message:@"請重新操作" delegate:nil cancelButtonTitle:@"確認" otherButtonTitles:nil];
            [alert show];
        }
    }
}
-(void)actSeparateArrayByTowards:(NSArray*)arrayToBeSeparated
{
//    NSMutableArray * arrayForward = [NSMutableArray new];
//    NSMutableArray * arrayBackward = [NSMutableArray new];
//    for(NSMutableDictionary * dictionaryStop in arrayTobeSeparated)
//    {
//        NSInteger integerToward = [[dictionaryStop objectForKey:@"GoBack"]integerValue];
//        switch (integerToward)
//        {
//            case 0:
//            {
//                [arrayForward addObject:dictionaryStop];
//            }
//                break;
//            case 1:
//            {
//                [arrayBackward addObject:dictionaryStop];
//            }
//                break;
//                
//            default:
//                break;
//        }
//    }
    
    dictionaryBackwardStops = [NSMutableDictionary dictionaryWithDictionary:[arrayToBeSeparated objectAtIndex:1]];
    dictionaryForwardStops = [NSMutableDictionary dictionaryWithDictionary:[arrayToBeSeparated objectAtIndex:0]];
    /*
     若路線為單向公車，則arrBackwardStops.count會為0，此時須將返程按鈕隱藏
     按鈕顯示白色邊框
     Andy 20150806
    */
    
    NSArray *arrBackwardStops = [NSArray arrayWithArray:[dictionaryBackwardStops objectForKey:@"Stop"]];
    if (arrBackwardStops.count == 0) {
        self.btnBackward.hidden = YES;
        isOneWay = YES;
    }else{
        self.btnBackward.hidden = NO;
        isOneWay = NO;
    }
    if ([self.btnForward isSelected]) {
        self.btnForward.layer.borderWidth = 1;
        self.btnForward.layer.borderColor = [UIColor whiteColor].CGColor;
    }
    if ([self.btnForward isSelected])
    {
        arrayTableviewStops = [dictionaryForwardStops objectForKey:@"Stop"];
//        self.btnForward.layer.borderWidth = 1;
//        self.btnForward.layer.borderColor = [UIColor whiteColor].CGColor;
//        self.btnBackward.layer.borderWidth = 0;
    }
    else if ([self.btnBackward isSelected])
    {
        arrayTableviewStops = [dictionaryBackwardStops objectForKey:@"Stop"];
//        self.btnBackward.layer.borderWidth = 1;
//        self.btnBackward.layer.borderColor = [UIColor whiteColor].CGColor;
//        self.btnForward.layer.borderWidth = 0;
    }
    integerUpdateTime = 0;
    [self.tableViewMain reloadData];
}

-(void)actSwipe{
    
    swipeToLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(_swipeLeftOrRight:)];
    swipeToRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(_swipeLeftOrRight:)];
    swipeToLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    swipeToRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.tableViewMain addGestureRecognizer:swipeToLeft];
    [self.tableViewMain addGestureRecognizer:swipeToRight];
    
}
-(void)_swipeLeftOrRight:(UISwipeGestureRecognizer *)gesture{
    
    if (gesture == swipeToLeft && !isOneWay) {
        [self.btnBackward setSelected:YES];
        [self.btnForward setSelected:NO];
        arrayTableviewStops = [dictionaryBackwardStops objectForKey:@"Stop"];
        self.btnBackward.layer.borderColor = [UIColor whiteColor].CGColor;
        self.btnBackward.layer.borderWidth = 1;
        self.btnForward.layer.borderWidth = 0;

    }else if (gesture == swipeToRight) {
        [self.btnForward setSelected:YES];
        [self.btnBackward setSelected:NO];
        arrayTableviewStops = [dictionaryForwardStops objectForKey:@"Stop"];
        self.btnForward.layer.borderColor = [UIColor whiteColor].CGColor;
        self.btnForward.layer.borderWidth = 1;
        self.btnBackward.layer.borderWidth = 0;
    }
    [self.tableViewMain reloadData];
}
#pragma mark - tableview Delegate&DataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrayTableviewStops.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //尋找tableview可回收Cell(需注意cell.xib要設定identifier,回收機制才有用)
    busDynamicCell * cell = (busDynamicCell*)[tableView dequeueReusableCellWithIdentifier:@"busDynamicCell"];
    
    //若無可回收Cell則由Bundle取得
    if (cell == nil)
    {
        NSArray *nib=[[NSBundle mainBundle]loadNibNamed:@"busDynamicCell" owner:self options:nil];
        for (id object in nib)
        {
            if ([object isKindOfClass:[busDynamicCell class]])
            {
                cell = (busDynamicCell*)object;
                break;
            }
        }
    }
    NSDictionary * dictionaryRouteStop = [arrayTableviewStops objectAtIndex:indexPath.row];
    
    //站序
    [cell.labelSequence setText:[NSString stringWithFormat:@"%ld",(long)(indexPath.row+1)]];
    
    //站名
    [cell.labelStopName setText:[dictionaryRouteStop objectForKey:@"StopName"]];
    
    //到站時間及底色
//    NSInteger integerTimeCheck = [[dictionaryRouteStop objectForKey:@"TimeId"]integerValue];
    NSString * stringTime = [dictionaryRouteStop objectForKey:@"Time"];
    
    NSString * stringImageName;
    
    if ([stringTime isEqualToString:@"未發車"])
    {
        stringImageName = @"dym_cell_time_background_gray";//未發車
    }
    else
        if ([stringTime isEqualToString:@"交管不停靠"])
        {
            stringImageName = @"dym_cell_time_background_gray";//交管不停靠
        }
        else
            if ([stringTime isEqualToString:@"末班已駛離"])
            {
                stringImageName = @"dym_cell_time_background_gray";//末班已駛離
            }
            else
                if ([stringTime isEqualToString:@"今日未營運"])
                {
                    stringImageName = @"dym_cell_time_background_gray";//今日未營運
                }
    
    
    if ([stringTime rangeOfString:@":"].length>0)
    {
        stringImageName = @"dym_cell_time_background_green";
    }
    else
        if (stringTime.integerValue>=5)
        {
            stringImageName = @"dym_cell_time_background_green";
            stringTime = [stringTime stringByAppendingString:@"分"];
            
        }
        else
            if (stringTime.integerValue>2)
            {
                stringImageName = @"dym_cell_time_background_orange";
                stringTime = [stringTime stringByAppendingString:@"分"];
            }
            else
                if (stringTime.integerValue>0 || [stringTime isEqualToString:@"進站中"])
                {
                    stringImageName = @"dym_cell_time_background_red";
                    stringTime = @"進站中";
                }
    
    
    [cell.imageTimeBackground setImage:[UIImage imageNamed:stringImageName]];
    [cell.labelTime setText:stringTime];
    
    
    //加上車牌
    NSString * stringBusPlate = [dictionaryRouteStop objectForKey:@"Car"];
    
    NSString * stringBusPlatePrevious;
    if (indexPath.row >0)
    {
        stringBusPlatePrevious = [[arrayTableviewStops objectAtIndex:indexPath.row-1]objectForKey:@"Car"];
    }
    
    if (stringBusPlatePrevious)
    {
        if ([stringBusPlatePrevious isEqualToString:stringBusPlate])
        {
            stringBusPlate = nil;
        }
    }
    if ([stringBusPlate isKindOfClass:[NSNull class]]||[stringBusPlate isEqualToString:@""])
    {
        stringBusPlate = nil;
    }
    
    [cell.labelBusPlate setText:stringBusPlate];
    /*
     edit Cooper 2015/07/27
     將車牌文字大小依文字的多寡做縮放
     */
    cell.labelBusPlate.adjustsFontSizeToFitWidth = YES;

    
    //設定車輛種類圖示
    NSString * stringImageBusType = nil;
    
    if (stringBusPlate)
    {
        [cell.viewBusArrived setHidden:NO];
        NSString * stringBusType = [dictionaryRouteStop objectForKey:@"CarType"];
        if ([stringBusType isEqualToString:@"normal"])
        {
            stringImageBusType = @"dym_cell_busType_normal";
        }
        else
            if ([stringBusType isEqualToString:@"lfv"])
            {
                stringImageBusType = @"dym_cell_busType_lfv";
            }
            else
                if ([stringBusType isEqualToString:@"ev"])
                {
                    stringImageBusType = @"dym_cell_busType_ev";
                }
                else
                {
                    stringImageBusType = nil;
                }
    }
    else
    {
        [cell.viewBusArrived setHidden:YES];
    }
    [cell.imageBusType setImage:[UIImage imageNamed:stringImageBusType]];
    
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //選擇的單一站牌資料, 建立成mutable dictionary
    dictionarySelectedStop = [NSMutableDictionary dictionaryWithDictionary:[arrayTableviewStops objectAtIndex:indexPath.row]];
    
    
    //將路線的資料加入單一站牌
    NSDictionary * dictionarySelectedOrigin = nil;
    
    if ([self.btnForward isSelected])
    {
        dictionarySelectedOrigin = dictionaryForwardStops;
    }
    else
        if ([self.btnBackward isSelected])
        {
            dictionarySelectedOrigin = dictionaryBackwardStops;
        }
    
    NSArray * arrayAllKeys = [dictionarySelectedOrigin allKeys];
    for (NSString * stringKey in arrayAllKeys)
    {
        if (![stringKey isEqualToString:@"Stop"])
        {
            [dictionarySelectedStop setObject:[dictionarySelectedOrigin objectForKey:stringKey] forKey:stringKey];
        }
    }
    
    
    //animation
    [self.viewCellSelectedMenu setAlpha:0.1];
    [self actShowFunctionMenu];
    [UIView beginAnimations:@"showMenu" context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [self.viewCellSelectedMenu setAlpha:1.0];
    [UIView commitAnimations];  
    
    
}
#pragma mark - UI control
-(void)actUpdateTimeLabel
{
    [self.labelUpdateTime setText:[NSString stringWithFormat:@"%ld",(long)integerUpdateTime]];
}
-(void)stopActivityIndicator
{
    [self.activityIndicator stopAnimating];
//    [self.tableViewMain setUserInteractionEnabled:YES];
}
-(void)startActivityIndicator
{
//    [self.tableViewMain setUserInteractionEnabled:NO];
    [self.activityIndicator startAnimating];
}
//我的最愛,到站提醒menu
-(void)actShowFunctionMenu
{
    if (self.viewCellSelectedMenu.frame.origin.x >= self.ContentV.frame.size.width)
    {
        CGRect frame = self.ContentV.bounds;
        [self.viewCellSelectedMenu setFrame:frame];
    }
}
-(void)actHideFunctionMenu
{
    if (self.viewCellSelectedMenu.frame.origin.x <= self.ContentV.frame.size.width)
    {
        //設定menu的Frame與ContainV同大小 並放置於右側畫面外
        CGRect frameNew = self.ContentV.bounds;
        frameNew.origin.x = self.ContentV.frame.size.width;
        [self.viewCellSelectedMenu setFrame:frameNew];
    }
}

#pragma mark - IBAction
- (IBAction)actBtnTowardTouchUpInside:(UIButton*)btnSelect
{
    if (![btnSelect isSelected])
    {
        if (btnSelect == self.btnForward)
        {
//            [self.btnForward setSelected:YES];
//            [self.btnBackward setSelected:NO];
//            arrayTableviewStops = [dictionaryForwardStops objectForKey:@"Stop"];
//            self.btnForward.layer.borderColor = [UIColor whiteColor].CGColor;
//            self.btnForward.layer.borderWidth = 1;
//            self.btnBackward.layer.borderWidth = 0;
            [self _swipeLeftOrRight:swipeToRight];
        }
        else
        {
//            [self.btnForward setSelected:NO];
//            [self.btnBackward setSelected:YES];
//            arrayTableviewStops = [dictionaryBackwardStops  objectForKey:@"Stop"];
//            self.btnBackward.layer.borderColor = [UIColor whiteColor].CGColor;
//            self.btnBackward.layer.borderWidth = 1;
//            self.btnForward.layer.borderWidth = 0;
            [self _swipeLeftOrRight:swipeToLeft];
        }
    }
}


- (IBAction)actBtnMenuTouchUpInside:(UIButton*)sender
{
    
    //animation
    [UIView beginAnimations:@"hideMenu" context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [self.viewCellSelectedMenu setAlpha:0.0];
    [UIView commitAnimations];
    
    [self actHideFunctionMenu];

    NSString * stringAlertTitle = nil;
    NSString * stringAlertMessage = nil;
    NSString * stringAlertCancelBtn = @"確認";
    NSString * stringAlertOtherBtn = nil;
    
    switch (sender.tag)
    {
        case DynamicMenuButtonTypeAddToFavorite:
        {
            DataManagerResult result = [DataManager favoriteAddFromDictionary:dictionarySelectedStop];
            switch (result)
            {
                case DataManagerResultExist:
                {
                    stringAlertTitle = @"加入我的最愛";
                    stringAlertMessage = [NSString stringWithFormat:@"加入失敗, 此項目已在列表中"];
                }
                    break;
                    
                case DataManagerResultSuccess:
                {
                    stringAlertTitle = @"加入我的最愛";
                    stringAlertMessage = [NSString stringWithFormat:@"加入成功"];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        case DynamicMenuButtonTypeAddToNotification:
        {
            NSString * stringUrl = [NotificationDetailViewController urlStringFromDictionary:dictionarySelectedStop byType:NotificationUpdateTypeAdd];
            [appDelegate.requestManager addRequestWithKey:@"NotificationAdd" andUrl:stringUrl byType:RequestDataTypeString];
        }
            break;
        case DynamicMenuButtonTypeLinesNearStop:
        {
            if (!self.viewControllerStopNearLines)
            {
                self.viewControllerStopNearLines = [[stopNearLinesViewController alloc]initWithNibName:@"stopNearLinesViewController" bundle:nil];
            }
            self.viewControllerStopNearLines.selectedStop = dictionarySelectedStop;
            
            [self.navigationController pushViewController:self.viewControllerStopNearLines animated:YES];
        }
            break;
            
        default:
            break;
    }
    
    if (stringAlertMessage && stringAlertTitle)
    {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:stringAlertTitle message:stringAlertMessage delegate:nil cancelButtonTitle:stringAlertCancelBtn otherButtonTitles:stringAlertOtherBtn, nil];
        [alert show];
    }


}

- (IBAction)actBtnUpdateTouchUpInside:(id)sender
{
    [self actQueryData];
}

-(void)actInsertWebView
{
//    if (!webViewControllerRoute)
//    {
//        webViewControllerRoute = [[webViewController alloc]initWithNibName:@"webViewController" bundle:nil];
//        webViewControllerRoute.view.frame = self.ContentV.bounds;
//    }
//    webViewControllerRoute.delegate = self;
//    [self addChildViewController:webViewControllerRoute];
//    [self.ContentV insertSubview:webViewControllerRoute.view belowSubview:SilderMenu];
//    NSLog(@"\ncontentV frame %@\nwebView frame %@",NSStringFromCGRect(self.ContentV.frame),NSStringFromCGRect(webViewControllerRoute.view.frame));
}
-(void)actRemoveWebView
{
//    if (webViewControllerRoute.parentViewController == self)
//    {
//    webViewControllerRoute.delegate = nil;
//    [webViewControllerRoute.view removeFromSuperview];
//    [webViewControllerRoute removeFromParentViewController];
//    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self actHideFunctionMenu];
}
#pragma mark - slide uicontrol
-(void)slideViewController:(id)viewController didTappedBackButton:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)slideViewController:(id)viewController setAdditionalButton:(UIButton *)button
{
    [button setImage:[UIImage imageNamed:@"slide_list"] forState:UIControlStateNormal];
}
-(void)slideViewController:(id)viewController didTappedAdditionalButton:(UIButton *)button
{
    if (!self.viewControllerTimeList)
    {
        self.viewControllerTimeList = [[TimeListViewController alloc]init];
    }
    self.viewControllerTimeList.selectedRoute = self.selectedRoute;

    [self.navigationController pushViewController:self.viewControllerTimeList animated:YES];
}
-(void)slideViewController:(id)viewController setTitleLabel:(UILabel *)label
{
    [label setText:@"公車動態"];
}
#pragma mark - updateTimer delegate
-(void)updateTimerTick:(NSUInteger)updateTime
{
    if (integerUpdateTime%10 == 0)
    {
        [self actQueryData];
    }
    [self.labelUpdateTime setText:[NSString stringWithFormat:@"%ld",(long)integerUpdateTime++]];
}

@end
