//
//  nearStopViewController.m
//  i84Taoyuan
//
//  Created by TMS_APPLE on 2014/9/1.
//  Copyright (c) 2014年 ＴＭＳ 景翊科技. All rights reserved.
//

#import "nearStopViewController.h"
#import "AppDelegate.h"
#import "SlideViewController.h"
#import "ShareTools.h"
//#import "ASINetworkQueue.h"
//#import "ASIHTTPRequest.h"
#import "NearStopCell.h"
#import "stopMapViewController.h"
#import "DataManager+Route.h"

//http://117.56.151.240/Taoyuan/NewAPI/API/NearByStop.ashx?lat=24.9540367126465&lon=121.223678588867&range=700
#define APIRouteByCoordinate @"%@/NewAPI/API/NearByStop.ashx?Lon=%.6f&Lat=%.6f&Range=%ld"

@interface nearStopViewController ()
<
SlideViewControllerUIControl
,UpdateTimerDelegate
,RequestManagerDelegate
>
{
    NSMutableDictionary * LeftMenu_BackBtn;

//    ASINetworkQueue * queueASIRequests;
//    NSDictionary * dictionaryAPI;
    NSInteger intQueryFailCount;
    CLLocation * cllocationHere;//目前取得的座標
    CLLocation * cllocationQuery;//傳入API時的座標,用來判斷若距離太近不重新send query,避免loading過大
    NSInteger integerSelectedDistance;
    CLLocationManager * locationManager;
    NSArray * arrayData;
    NSInteger integerUpdateTime;
    
//    NSMutableArray * arrayRoutes;
}
@property (strong, nonatomic) stopMapViewController * viewControllerStopMap;
@end

@implementation nearStopViewController
#pragma mark - Set Timer
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
    [self actSetCLLocationManager];
}
-(void)viewWillAppear:(BOOL)animated
{
    [locationManager startUpdatingLocation];

    appDelegate.updateTimer.delegate = self;
    appDelegate.requestManager.delegate = self;
    appDelegate.viewControllerSlide.UIControl = self;
    [self actQueryData];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [locationManager stopUpdatingLocation];

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
    arrayData = @[];
    [self.tableViewMain reloadData];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Env Setting
-(void)actSetCLLocationManager
{
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDelegate:self];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
}

-(void)actQueryData
{
//    arrayRoutes =[DataManager getData];
    if (integerSelectedDistance<=0)//初始時距離按鈕未選擇過
    {
        for (id sender in self.viewDistanceButtons.subviews)
        {
            if ([sender isKindOfClass:[UIButton class]] && [sender isSelected])
            {
                integerSelectedDistance = [sender tag];
                break;
            }
        }
    }
//    cllocationHere = [[CLLocation alloc]initWithLatitude:24.9536 longitude:121.2257];
    NSString * stringUrl = [NSString stringWithFormat:APIRouteByCoordinate,APIServer,cllocationHere.coordinate.longitude,cllocationHere.coordinate.latitude,(long)integerSelectedDistance];
    NSLog(@"查詢網址_%@", stringUrl);
    [appDelegate.requestManager addRequestWithKey:@"NearStop" andUrl:stringUrl byType:RequestDataTypeJson];
//
//    dictionaryAPI = @{
//                      @1:[NSString stringWithFormat:APIRouteByCoordinate,cllocationHere.coordinate.longitude,cllocationHere.coordinate.latitude,(long)integerSelectedDistance],
//                      @"server":APIServer
//                      };
//    [self SendQueryRequest:1];
}

#pragma mark - UI Control
-(void)actShowMapAtStop:(id)idStop
{
    if (!self.viewControllerStopMap)
    {
        self.viewControllerStopMap = [[stopMapViewController alloc]initWithNibName:@"stopMapViewController" bundle:nil];
    }
    self.viewControllerStopMap.idSelectedStop = idStop;
    [self.navigationController pushViewController:self.viewControllerStopMap animated:YES];
}
//-(void)actHideMap
//{
//    if (mapViewController)
//    {
//        [mapViewController.view removeFromSuperview];
//        [mapViewController removeFromParentViewController];
//    }
//}
-(void)actUpdateTimeLabel
{
    [self.labelUpdateTime setText:[NSString stringWithFormat:@"%ld",(long)integerUpdateTime]];
}
-(void)stopActivityIndicator
{
    [self.activityIndicator stopAnimating];
//    [self.view setUserInteractionEnabled:YES];
}
-(void)startActivityIndicator
{
//    [self.view setUserInteractionEnabled:NO];
    [self.activityIndicator startAnimating];
}
#pragma mark - IBAction


- (IBAction)actBtnDistanceTouchUpInside:(id)sender
{
    for (id button in self.viewDistanceButtons.subviews)
    {
        [(UIButton*)button setSelected                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              :NO];
    }
    [sender setSelected:YES];
    integerSelectedDistance = [sender tag];
    [self actQueryData];
}

- (IBAction)actBtnUpdateTouchUpInside:(id)sender
{
    [self actQueryData];
}
#pragma mark - SlideMenu UIControl
//-(void)slideViewController:(id)viewController setAdditionalButton:(UIButton *)button
//{
//    [button setImage:[UIImage imageNamed:@"edit"] forState:UIControlStateNormal];
//}
//-(void)slideViewController:(id)viewController didTappedAdditionalButton:(UIButton *)button
//{
//    [button setSelected:![button isSelected]];
//    
//    if ([button isSelected])
//    {
//        [self.viewControllerList.tableViewResult setEditing:YES animated:YES];
//    }
//    else
//    {
//        [self.viewControllerList.tableViewResult setEditing:NO animated:YES];
//    }
//}
-(void)slideViewController:(id)viewController setTitleLabel:(UILabel *)label
{
    label.text = @"附近站牌";
}
#pragma mark - CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    cllocationHere = [locations lastObject];
//    cllocationHere = [[CLLocation alloc]initWithLatitude:24.179  longitude:120.645];
    if (!cllocationQuery )
    {
        cllocationQuery = cllocationHere;
    }
    else
        if ([cllocationQuery distanceFromLocation:cllocationHere]>15.0)
        {
            cllocationQuery = cllocationHere;
        }

    if(cllocationQuery == cllocationHere && cllocationQuery.coordinate.latitude>0 && cllocationQuery.coordinate.longitude>0)
    {
        [self actQueryData];
    }
}
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if([error code] == kCLErrorDenied)
    {
//        self.EmptyLbl.text = @"請開啓GPS權限";
    }
    else
    {
//        self.EmptyLbl.text = @"GPS接收訊號失敗";
    }
    NSLog(@"GPS Error Code %ld",(long)[error code]);
    NSLog(@"%@",[error localizedDescription]);
}

#pragma mark - tableview Delegate&DataSource
//-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    NSString * stringStopName = [[arrayData objectAtIndex:section]objectForKey:@"StopName"];
//    NSString * stringDistance = [[arrayData objectAtIndex:section]objectForKey:@"distance"];
    
//    NSString * stringTitle = [NSString stringWithFormat:@"車站 - %@",stringStopName];
//    NSString * stringTitle = [NSString stringWithFormat:@"%@ - 距離%.1f公尺",stringStopName,stringDistance.doubleValue];
//    return stringStopName;
//}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    return [[[arrayData objectAtIndex:section]objectForKey:@"Path"]count];
    return arrayData.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
   return 65;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NearStopCell * cell = (NearStopCell*)[tableView dequeueReusableCellWithIdentifier:@"NearStopCell"];
    
    //若無可回收Cell則由Bundle取得
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"NearStopCell" owner:self options:nil];
        for (id object in nib)
        {
            if ([object isKindOfClass:[NearStopCell class]])
            {
                cell = (NearStopCell*)object;
                break;
            }
        }
    }
//    NSDictionary * dictionaryRouteDetail = (NSDictionary*)[[[arrayData objectAtIndex:indexPath.section]objectForKey:@"Path"] objectAtIndex:indexPath.row];

    NSDictionary * dictionaryStop = [arrayData objectAtIndex:indexPath.row];
//    NSString * stringRouteName = [[arrayData objectAtIndex:indexPath.section]objectForKey:@"StopName"];
    if (dictionaryStop)
    {
        NSString * stringDeparture = [dictionaryStop objectForKey:@"Dept"];
        NSString * stringDestination = [dictionaryStop objectForKey:@"Dest"];
        NSString * stringPath;
        NSString * stringDirectionSymbol = @"往 ";
        if (!stringDeparture||!stringDestination)
        {
            stringDeparture = @"";
            stringDestination = @"";
            stringDirectionSymbol = @"";
        }
        if ([[dictionaryStop objectForKey:@"Goback"]isEqualToString:@"2"])
        {
            stringPath = [NSString stringWithFormat:@"%@%@",stringDirectionSymbol,stringDestination];
        }
        else
            if ([[dictionaryStop objectForKey:@"Goback"]isEqualToString:@"1"])
        {
            stringPath = [NSString stringWithFormat:@"%@%@",stringDirectionSymbol,stringDestination];
        }
        [cell.labelRouteToward setText:stringPath];
//        [cell.labelRouteToward setHidden:NO];
    }
//    else
//    {
//        [cell.labelRouteToward setHidden:YES];
//    }

    [cell.labelRouteName setText:[dictionaryStop objectForKey:@"PathName"]];
    [cell.labelSerialNumber setText:[NSString stringWithFormat:@"%ld",(long)indexPath.row + 1]];
    [cell.labelStopName setText:[dictionaryStop objectForKey:@"StopName"]];
    
    
    //到站時間判斷
    NSString * stringTime = [dictionaryStop objectForKey:@"Time"];
    
    if([self isPureNumandCharacters:stringTime]) {
         stringTime = [stringTime stringByAppendingString:@"分"];
    }
    
    [cell.labelRouteArriveTime setText:stringTime];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *stringStopName = [[arrayData objectAtIndex:indexPath.row]objectForKey:@"StopName"];
    NSMutableDictionary * dictionaryStop = [NSMutableDictionary dictionaryWithDictionary:[arrayData objectAtIndex:indexPath.row]];
    [dictionaryStop setObject:stringStopName forKey:@"StopName"];
    [self actShowMapAtStop:dictionaryStop];
    
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
    if ([key isEqualToString:@"NearStop"])
    {
        NSArray * arrayFronJson = (NSArray*)jsonSerialization;
        
        arrayData = arrayFronJson;
        [self.tableViewMain reloadData];
        
        integerUpdateTime = 1;
    }
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

//判斷字串是否都是數字
- (BOOL)isPureNumandCharacters:(NSString *)string
{
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
    if(string.length > 0)
    {
        return NO;
    }
    return YES;
}

@end
