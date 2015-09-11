//
//  stopNearLinesViewController.m
//  i84Taoyuan
//
//  Created by TMS_APPLE on 2014/9/1.
//  Copyright (c) 2014年 ＴＭＳ 景翊科技. All rights reserved.
//

#import "stopNearLinesViewController.h"
#import "GDataXMLNode.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "AppDelegate.h"
#import "ShareTools.h"
#import "stopNearLineCell.h"
#import "SlideViewController.h"

#define APINearRoute @"%@/NewAPI/API/CrossRoute.ashx?stopname=%@"

@interface stopNearLinesViewController ()
<
RequestManagerDelegate
,SlideViewControllerUIControl
,UpdateTimerDelegate
>
{
    NSMutableDictionary * LeftMenu_BackBtn;

    NSDictionary * dictionaryAPI;
    ASINetworkQueue * queueASIRequests;
    NSInteger intQueryFailCount;
    NSDictionary * dictionarySelectedStop;
    NSArray * arrayTableViewRoutes;
    NSInteger integerUpdateTime;
}
@end

@implementation stopNearLinesViewController

//#pragma mark - Set Timer
//-(void)actTimer
//{
//    [self performSelectorOnMainThread:@selector(actUpdateTimeLabel) withObject:nil waitUntilDone:NO];
//    
//    integerUpdateTime++;
//    
//    if (integerUpdateTime%UpdateTime == 0)
//    {
//        [self SendQueryRequest:1];
//    }
//}

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

//    [self actSetASIQueue];
//    
//    [self actSetQueryAPI];
//
//    [self SendQueryRequest:1];
    
//    [self actSetTitle];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated
{
    appDelegate.updateTimer.delegate = self;
    appDelegate.requestManager.delegate = self;
    appDelegate.viewControllerSlide.UIControl = self;
    [self actQueryData];
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
    arrayTableViewRoutes = @[];
    [self.tableViewRoutes reloadData];
}
-(void)actQueryData
{
    NSString * stringUrl = [NSString stringWithFormat:APINearRoute,APIServer,[self.selectedStop objectForKey:@"StopName"]];
    [appDelegate.requestManager addRequestWithKey:@"StopPassLines" andUrl:stringUrl byType:RequestDataTypeJson];
}
#pragma mark - Env Setting
//-(void)actSetTitle
//{
//    [self.labelTitle setText:[NSString stringWithFormat:@"%@(%@)",[appDelegate.selectedStop objectForKey:@"StopName"],[appDelegate.selectedStop objectForKey:@"nameZh"]]];
//}
//ASIQueue設定
//-(void)actSetASIQueue
//{
//    queueASIRequests = [[ASINetworkQueue alloc] init];
//    queueASIRequests.maxConcurrentOperationCount = 2;
//    
//    // ASIHTTPRequest 默認的情況下，queue 中只要有一個 request fail 了，整個 queue 裡的所有 requests 也都會被 cancel 掉
//    [queueASIRequests setShouldCancelAllRequestsOnFailure:NO];
//    
//    // go 只需要執行一次
//    // [queueASIRequests go];
//}
//-(void)actSetQueryAPI
//{
//    dictionarySelectedStop = (NSDictionary*)appDelegate.selectedStop;
//    dictionaryAPI = @{
//                      @1: [NSString stringWithFormat:APINearRoute,[ShareTools GetUTF8Encode:[dictionarySelectedStop objectForKey:@"StopName"]]],
//                      @"server":APIServer
//                      };
//
//}

#pragma mark - UI Control
-(void)actUpdateTimeLabel
{
    [self.labelUpdateTime setText:[NSString stringWithFormat:@"%ld",(long)integerUpdateTime]];
}
-(void)stopActivityIndicator
{
    [self.activityIndicator stopAnimating];
//    [self.ContentV setUserInteractionEnabled:YES];
}
-(void)startActivityIndicator
{
//    [self.ContentV setUserInteractionEnabled:NO];
    [self.activityIndicator startAnimating];
}
#pragma mark - IBAction
- (IBAction)actBtnUpdateTouchUpInside:(id)sender
{
    [self actQueryData];
}


#pragma mark - Query API


#pragma mark - tableview Delegate&DataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrayTableViewRoutes.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    UITableViewCell * cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    //尋找tableview可回收Cell(需注意cell.xib要設定identifier,回收機制才有用)
    stopNearLineCell * cell = (stopNearLineCell*)[tableView dequeueReusableCellWithIdentifier:@"stopNearLineCell"];
    
    //若無可回收Cell則由Bundle取得
    if (cell == nil)
    {
        NSArray * nib = [[NSBundle mainBundle]loadNibNamed:@"stopNearLineCell" owner:self options:nil];
        for (id object in nib)
        {
            if ([object isKindOfClass:[stopNearLineCell class]])
            {
                cell = (stopNearLineCell*)object;
                break;
            }
        }
    }
    NSDictionary * dictionaryRoute = [arrayTableViewRoutes objectAtIndex:indexPath.row];
    NSString * stringPath;
//    stringPath = [NSString stringWithFormat:@"%@ -> %@",[dictionaryRoute objectForKey:@"Dept"],[dictionaryRoute objectForKey:@"Dest"]];
    stringPath = [NSString stringWithFormat:@"往%@", [dictionaryRoute objectForKey:@"Dest"]];
    
//    if ([[dictionaryRoute objectForKey:@"GoBack"]isEqualToString:@"1"])
//    {
//        stringPath = [NSString stringWithFormat:@"去程: %@ -> %@",[dictionaryRoute objectForKey:@"Dept"],[dictionaryRoute objectForKey:@"Dest"]];
//    }
//    else
//    {
//        stringPath = [NSString stringWithFormat:@"返程: %@ -> %@",[dictionaryRoute objectForKey:@"Dest"],[dictionaryRoute objectForKey:@"Dept"]];
//    }
    
    NSString * CarPlate = [dictionaryRoute objectForKey:@"Car"];
    NSString * CarType = [dictionaryRoute objectForKey:@"CarType"];;
    NSString * imageBusType = @"";
    [cell.labelBusPlate setText:CarPlate];
    
    if (![CarPlate isEqualToString:@""])
    {
        if ([CarType isEqualToString:@"normal"])
        {
            imageBusType = @"dym_cell_busType_normal";
        }
        else if ([CarType isEqualToString:@"lfv"])
        {
            imageBusType = @"dym_cell_busType_lfv";
        }
        else if ([CarType isEqualToString:@"ev"])
        {
            imageBusType = @"dym_cell_busType_ev";
        }
        else
        {
            imageBusType = @"";
        }
        [cell.imageBusType setImage:[UIImage imageNamed:imageBusType]];
    }
    
    [cell.labelRouteName setText:[dictionaryRoute objectForKey:KeyRouteName]];
    [cell.labelSerialNumber setText:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
    [cell.labelRouteToward setText:stringPath];
    
    //到站時間判斷
    //到站時間及底色
    NSString * stringTime = [dictionaryRoute objectForKey:@"Time"];
    
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
    
    
    [cell.imageViewTimeBackground setImage:[UIImage imageNamed:stringImageName]];
    [cell.labelRouteArriveTime setText:stringTime];

    return cell;
}
//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    AppDelegate * delegate = [[UIApplication sharedApplication] delegate];
//    delegate.selectedRoute = arrayTableviewRoutes[indexPath.row];
//    [delegate SwitchViewer:2];
//}
#pragma mark - slide uicontrol protocol
-(void)slideViewController:(id)viewController didTappedBackButton:(UIButton *)backUI
{
    [self.navigationController popViewControllerAnimated:YES];
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
-(void)slideViewController:(id)viewController setTitleLabel:(UILabel *)label
{
    [label setText:[self.selectedStop objectForKey:@"StopName"]];
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
    if ([key isEqualToString:@"StopPassLines"])
    {
        NSArray * arrayFronJson = (NSArray*)jsonSerialization;
        
        arrayTableViewRoutes = arrayFronJson;
        [self.tableViewRoutes reloadData];

        integerUpdateTime = 1;
    }
}

@end
