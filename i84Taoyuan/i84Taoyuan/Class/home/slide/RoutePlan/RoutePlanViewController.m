//
//  RoutePlanViewController.m
//  i84Taoyuan
//
//  Created by TMS_APPLE on 2014/8/21.
//  Copyright (c) 2014年 TMS. All rights reserved.
//
#import <CoreLocation/CoreLocation.h>
#import "RoutePlanViewController.h"
#import "AppDelegate.h"
#import "ListViewController.h"
#import "MapSettingViewController.h"
#import "LocationOptionsViewController.h"
#import "ResultViewController.h"
#import "DataManager+RoutePlan.h"

#define APIHotSpots @"%@/NewAPI/API/HotPoint.ashx"

@interface RoutePlanViewController ()
<
RequestManagerDelegate
,SlideViewControllerUIControl
,ListViewControllerDelegate
,CLLocationManagerDelegate
,LocationOptionsViewControllerDelegate
,UITextFieldDelegate
,MapSettingViewControllerDelegate
>
{
    CLLocationManager * locationManager;
}
@property (strong, nonatomic) IBOutlet UITextField *textFieldStart;
@property (strong, nonatomic) IBOutlet UITextField *textFieldEnd;
@property (strong, nonatomic) IBOutlet UIButton *buttonSwap;
@property (strong, nonatomic) IBOutlet UILabel *labelNoResult;
@property (strong, nonatomic) IBOutlet UIView *viewContainer;

@property (strong, nonatomic) IBOutlet UIView *viewHotLinks;


@property (strong, nonatomic) NSMutableDictionary * dictionartLocationStart;
@property (strong, nonatomic) NSMutableDictionary * dictionartLocationEnd;
@property (strong, nonatomic) MapSettingViewController * viewControllerMapSetting;
@property (strong, nonatomic) LocationOptionsViewController * viewControllerLocationOptions;
@property (strong, nonatomic) ResultViewController * viewControllerResult;
@property (strong, nonatomic) NSMutableArray * arrayHotSpots;
@property (strong, nonatomic) NSMutableArray * arrayAddress;
@property (strong, nonatomic) NSMutableArray * arrayCollects;
- (IBAction)actBtnHotLinkTouchUpInside:(id)sender;
- (IBAction)actBtnSwapTouchUpInside:(id)sender;
- (IBAction)actBtnPlanSearchTouchUpInside:(id)sender;

@end

@implementation RoutePlanViewController

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
    [self actSetView];
    locationManager = [CLLocationManager new];

    self.dictionartLocationEnd = [NSMutableDictionary new];
    self.dictionartLocationStart = [NSMutableDictionary new];
}
- (void)viewWillAppear:(BOOL)animated
{
    if (locationManager)
    {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0){
            [locationManager requestAlwaysAuthorization];
            [locationManager requestWhenInUseAuthorization];
        }
        [locationManager startUpdatingLocation];
    }
    
    appDelegate.viewControllerSlide.UIControl = self;
    appDelegate.requestManager.delegate = self;
}
-(void)viewWillDisappear:(BOOL)animated
{
    if (locationManager)
    {
        [locationManager stopUpdatingLocation];
    }
    if (appDelegate.viewControllerSlide.UIControl == self)
    {
        appDelegate.viewControllerSlide.UIControl = nil;
    }
    if (appDelegate.requestManager.delegate == self)
    {
        appDelegate.requestManager.delegate = nil;
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)clearPlanData
{
    self.textFieldStart.text = @"";
    self.textFieldEnd.text = @"";
    self.dictionartLocationStart = [NSMutableDictionary new];
    self.dictionartLocationEnd = [NSMutableDictionary new];
}
#pragma mark - SlideMenu UIControl
-(void)slideViewController:(id)viewController setAdditionalButton:(UIButton *)button
{
    [button setImage:[UIImage imageNamed:@"slide_map"] forState:UIControlStateNormal];
}
-(void)slideViewController:(id)viewController didTappedAdditionalButton:(UIButton *)button
{
    [self actShowMap:button];
}
-(void)actShowMap:(id)sender
{
    if (!self.viewControllerMapSetting)
    {
        self.viewControllerMapSetting = [[MapSettingViewController alloc]initWithNibName:@"MapSettingViewController" bundle:nil];
    }
    self.viewControllerMapSetting.delegate = self;
    
    [self.navigationController pushViewController:self.viewControllerMapSetting animated:YES];
}

-(void)slideViewController:(id)viewController setTitleLabel:(UILabel *)label
{
    label.text = @"乘車規劃";
}

- (void) actSetStartPoint
{
    if (!self.dictionartLocationStart)
    {
        self.dictionartLocationStart = [NSMutableDictionary new];
    }
    
    NSLog(@"坐標Lat__%f",locationManager.location.coordinate.latitude);
    NSLog(@"坐標Lon__%f",locationManager.location.coordinate.longitude);
    
    if (locationManager.location.coordinate.latitude > 0.0 && locationManager.location.coordinate.longitude > 0.0)
    {
        [self actSetPlanLocation:self.dictionartLocationStart withName:@"目前位置" lat:[NSString stringWithFormat:@"%.6f",locationManager.location.coordinate.latitude] lon:[NSString stringWithFormat:@"%.6f",locationManager.location.coordinate.longitude]];
    }
    else
    {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"GPS座標取得失敗" message:@"本功能需使用GPS座標功能" delegate:nil cancelButtonTitle:@"確認" otherButtonTitles:nil];
        [alert show];
    }
}

-(NSString *)actPointToAddressLat:(float)lat actPointToAddressLon:(float)lon
{
    NSString * AddrApi =[NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&sensor=false&language=zh-tw", lat,lon];
    
    NSURL * url = [NSURL URLWithString:AddrApi];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    [request setHTTPMethod:@"GET"];
    NSHTTPURLResponse *response;
    NSError * error = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSString * AddressJson = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    AddressJson = [AddressJson stringByReplacingOccurrencesOfString:@" " withString:@""];

    NSArray *array01 = [AddressJson componentsSeparatedByString:@"geometry"];
    NSArray *array02 = [[array01 objectAtIndex:0] componentsSeparatedByString:@"formatted_address"];
    NSString * strAddress = [array02 objectAtIndex:1];
    strAddress = [strAddress stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    strAddress = [strAddress stringByReplacingOccurrencesOfString:@":" withString:@""];
    strAddress = [strAddress stringByReplacingOccurrencesOfString:@"," withString:@""];
    
    return strAddress;
}

#pragma mark - IBAction
- (IBAction)actBtnHotLinkTouchUpInside:(UIButton*)sender
{
    if ([sender.titleLabel.text isEqualToString:@"目前位置"])
    {
        [self actSetStartPoint];
    }
    else if ([sender.titleLabel.text hasPrefix:@"一鍵"])
    {
        [self actSetStartPoint];
        NSDictionary * dictionaryLocation = nil;
        NSDictionary * oneInfo = [NSDictionary new];
        if ([sender.titleLabel.text hasSuffix:@"回家"])
        {
            oneInfo = [DataManager getRoutePlanOneInfo:@"回家"];
            NSLog(@"搜尋到的資料%@",oneInfo);
            if(oneInfo.count > 0){
                [self actSetPlanLocation:self.dictionartLocationEnd withDictionary:oneInfo showTextType:@"Name"];
            } else {
                [self showAlertView:@"回家"];
            }
        }
        else if ([sender.titleLabel.text hasSuffix:@"公司"])
        {
            oneInfo = [DataManager getRoutePlanOneInfo:@"公司"];
            NSLog(@"搜尋到的資料%@",oneInfo);
            if(oneInfo.count > 0){
                [self actSetPlanLocation:self.dictionartLocationEnd withDictionary:oneInfo showTextType:@"Name"];
            } else {
                [self showAlertView:@"公司"];
            }
        }
        
        if (!dictionaryLocation)
        {
//            [self actShowMap:sender];
        }
        else
        {
            [self actSetPlanLocation:self.dictionartLocationStart withName:@"目前位置" lat:[NSString stringWithFormat:@"%.6f",locationManager.location.coordinate.latitude] lon:[NSString stringWithFormat:@"%.6f",locationManager.location.coordinate.longitude]];
            [self actSetPlanLocation:self.dictionartLocationEnd withDictionary:dictionaryLocation showTextType:@"Name"];
            [self actBtnPlanSearchTouchUpInside:nil];
        }
    }
    else if ([sender.titleLabel.text isEqualToString:@"熱門景點"])
    {
        if (self.arrayHotSpots.count>0)
        {
            [self actShowLocationArray:self.arrayHotSpots withMode:LocationOptionsCollectionModeAdd];
        }
        else
        {
            NSString * stringUrl = [NSString stringWithFormat:APIHotSpots,APIServer];
            [appDelegate.requestManager addRequestWithKey:@"HotSpots" andUrl:stringUrl byType:RequestDataTypeJson];
        }
    }
    else if ([sender.titleLabel.text isEqualToString:@"我的收藏"])
    {
        self.arrayCollects = [DataManager getRoutePlanDataList];
        NSLog(@"抓到的資料%@", self.arrayCollects);
        if (self.arrayCollects.count > 0)
        {
            [self actShowLocationArray:self.arrayCollects withMode:LocationOptionsCollectionModeDelete];
        } else {
            [appDelegate showAlertView:@"提示" setMessage:@"我的收藏尚未加入資料" setMessage:@"確定"];
        }
    }
    
}

- (IBAction)actBtnSwapTouchUpInside:(id)sender
{
    if (!self.dictionartLocationStart)
    {
        self.dictionartLocationStart = [NSMutableDictionary new];
    }
    if (!self.dictionartLocationEnd)
    {
        self.dictionartLocationEnd = [NSMutableDictionary new];
    }
    NSMutableDictionary * dictionaryTmp = self.dictionartLocationStart;
    self.dictionartLocationStart = self.dictionartLocationEnd;
    self.dictionartLocationEnd = dictionaryTmp;
    self.textFieldEnd.text = [self.dictionartLocationEnd objectForKey:@"Name"];
    self.textFieldStart.text = [self.dictionartLocationStart objectForKey:@"Name"];
}
- (IBAction)actBtnPlanSearchTouchUpInside:(id)sender
{
    if (self.textFieldEnd.text.length > 0 && self.textFieldStart.text.length > 0)
    {
        if (!self.viewControllerResult)
        {
            self.viewControllerResult = [[ResultViewController alloc]init];
        }
        self.viewControllerResult.dictionaryLocationStart = self.dictionartLocationStart;
        self.viewControllerResult.dictionaryLocationEnd = self.dictionartLocationEnd;
        [self.navigationController pushViewController:self.viewControllerResult animated:YES];
    }
    else
    {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"請先設定地點" message:@"起點及終點均需設定" delegate:nil cancelButtonTitle:@"確認" otherButtonTitles:nil];
        [alert show];
    }
}
#pragma mark - method
-(void)actSetView
{
    [self actChangeSubView:self.viewHotLinks];
}
-(void)actChangeSubView:(UIView*)subView
{
    if (self.viewContainer.subviews.count>0)
    {
        for (UIView * subViewOne in self.viewContainer.subviews)
        {
            [subViewOne removeFromSuperview];
        }
    }
    subView.frame = self.viewContainer.bounds;
    NSLog(@"Container:%@",NSStringFromCGRect(self.viewContainer.bounds));
    [self.viewContainer addSubview:subView];
}
-(void)actSetPlanLocation:(NSMutableDictionary*)location withName:(NSString*)name lat:(NSString*)lat lon:(NSString*)lon
{
    NSMutableDictionary * locationNew = [NSMutableDictionary new];
    if (location)
    {
        [location removeAllObjects];

        [locationNew setObject:lat forKey:@"Lat"];
        [locationNew setObject:lon forKey:@"Lon"];
        [locationNew setObject:name forKey:@"Name"];
        [self actSetPlanLocation:location withDictionary:locationNew showTextType:@"Name"];
    }
}

-(void)actSetPlanLocation:(NSMutableDictionary*)location withDictionary:(NSDictionary*)locationNew showTextType:(NSString *)showType
{
//    NSLog(@"設定看%@",locationNew);
//    NSString * strAddress = [self actPointToAddressLat:[[locationNew objectForKey:@"Lat"] floatValue] actPointToAddressLon:[[locationNew objectForKey:@"Lon"] floatValue]];
    
    NSString * showText = @"";
    if([showType isEqualToString:@"Address"])
        showText = [locationNew objectForKey:@"Address"];
    else
        showText = [locationNew objectForKey:@"Name"];
    
    if (location == self.dictionartLocationStart)
    {
        self.textFieldStart.text = showText;
//        self.textFieldStart.text = strAddress;
        self.dictionartLocationStart = [NSMutableDictionary dictionaryWithDictionary:locationNew];
    }
    else if (location == self.dictionartLocationEnd)
    {
        self.textFieldEnd.text = showText;
//        self.textFieldEnd.text = strAddress;
        self.dictionartLocationEnd = [NSMutableDictionary dictionaryWithDictionary:locationNew];
    }
}


-(void)actShowLocationArray:(NSMutableArray*)arrayLocation withMode:(LocationOptionsCollectionMode)mode
{
    if (!self.viewControllerLocationOptions)
    {
        self.viewControllerLocationOptions = [[LocationOptionsViewController alloc]initWithNibName:@"LocationOptionsViewController" bundle:nil];
    }
    self.viewControllerLocationOptions.delegate = self;
    self.viewControllerLocationOptions.arrayList = arrayLocation;
    self.viewControllerLocationOptions.collectionMode = mode;
    [self.navigationController pushViewController:self.viewControllerLocationOptions animated:YES];
}
#pragma mark - requestManager delegate
-(void)requestManager:(id)requestManager returnJSONSerialization:(NSJSONSerialization *)jsonSerialization withKey:(NSString *)key
{
    if ([key isEqualToString:@"HotSpots"])
    {
        self.arrayHotSpots = [[NSMutableArray alloc]initWithArray:(NSArray*)jsonSerialization];
        [self actShowLocationArray:self.arrayHotSpots withMode:LocationOptionsCollectionModeAdd];
    }
}

#pragma mark - LocationOptionsViewController Delegate
-(void)locationOptionsViewController:(UIViewController *)viewController withDictionary:(NSDictionary *)location andTarget:(LocationOptionsReturnTarget)target
{
    if (target == LocationOptionsReturnTargetStart)
    {
        [self actSetPlanLocation:self.dictionartLocationStart withDictionary:location showTextType:@"Name"];
    }
    else
        if (target == LocationOptionsReturnTargetEnd)
        {
            [self actSetPlanLocation:self.dictionartLocationEnd withDictionary:location showTextType:@"Name"];

        }
}
#pragma mark - UITextField Delegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [textField resignFirstResponder];

    [self actShowMap:textField];

//    if (self.arrayHotSpots.count>0)
//    {
//        [self actShowLocationArray:self.arrayHotSpots withMode:LocationOptionsCollectionModeAdd];
//    }
//    else
//    {
//        NSString * stringUrl = [NSString stringWithFormat:APIHotSpots,APIServer];
//        [appDelegate.requestManager addRequestWithKey:@"HotSpots" andUrl:stringUrl byType:RequestDataTypeJson];
//    }

    return NO;
}
-(void)mapSetting:(UIViewController *)viewController setLocation:(NSMutableDictionary *)location toStart:(BOOL)target
{
    NSMutableDictionary * dictionaryTmp = nil;
    if (target)
    {
        dictionaryTmp = self.dictionartLocationStart;
    }
    else
    {
        dictionaryTmp = self.dictionartLocationEnd;
    }
    [self actSetPlanLocation:dictionaryTmp withDictionary:location showTextType:@"Address"];
}

-(void)showAlertView:(NSString *)msg
{
    [appDelegate showAlertView:@"提示" setMessage:[NSString stringWithFormat:@"請先設定%@地點", msg] setMessage:@"確定"];
}


@end
