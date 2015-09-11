//
//  MapSettingViewController.m
//  i84Taoyuan
//
//  Created by TMS_APPLE on 2014/9/24.
//  Copyright (c) 2014年 TMS. All rights reserved.
//

#import "MapSettingViewController.h"
#import "AppDelegate.h"
#import "MapViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "Annotation.h"
#import "DataManager+Location.h"
#import "DataManager+RoutePlan.h"
#import "RoutePlanViewController.h"

#define APIGoogleKeyWords @"https://maps.googleapis.com/maps/api/geocode/json?address=%@,桃園&region=tw&language=Zh-Tw&sensor=true"
#define KeyDefaultLat 24.9535
#define KeyDefaultLon 121.2255

@interface MapSettingViewController ()
<
SlideViewControllerUIControl
,RequestManagerDelegate
,MapViewControllerDelegate
,UITextFieldDelegate
>
{
    NSString *selectType;
    NSDictionary * dictionaryGoogleResult;
    BOOL boolGetUserLocationNotFirst;
}
@property (strong, nonatomic) MapViewController * viewControllerMap;
@property (strong, nonatomic) IBOutlet UIView *viewFunctionBtns;
@property (strong, nonatomic) IBOutlet UIView *viewMap;
@property (strong, nonatomic) IBOutlet UITextField *textFieldSearch;
@property (strong, nonatomic) IBOutlet UIButton *buttonStart;
@property (strong, nonatomic) IBOutlet UIButton *buttonEnd;
@property (strong, nonatomic) IBOutlet UIButton *buttonHome;
@property (strong, nonatomic) IBOutlet UIButton *buttonOffice;
@property (strong, nonatomic) IBOutlet UIButton *buttonAddCollection;

@property (strong, nonatomic) NSMutableDictionary * dictionarySelectedLocation;
@property (strong, nonatomic) RoutePlanViewController * viewControllerRoutePlan;

- (IBAction)actBtnSearchTouchUpInside:(id)sender;
- (IBAction)actBtnFunctionTouchUpInside:(id)sender;

@end

@implementation MapSettingViewController
#pragma mark - Life cycle
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
    [self actSetView];
}
- (void)viewWillAppear:(BOOL)animated
{
    self.viewFunctionBtns.hidden = YES;
    appDelegate.viewControllerSlide.UIControl = self;
    appDelegate.requestManager.delegate = self;
    self.viewControllerMap.delegate = self;
    [self setMapMenu:self.menuMode];
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
}

-(void)setMapMenu:(MapSettingMenuMode)mode
{
//    float floatWidth = self.viewFunctionBtns.frame.size.width;
    float floatButtonWidth = self.buttonHome.frame.size.width;
    float floatButtonDistance = self.buttonOffice.frame.origin.x - self.buttonHome.frame.origin.x - floatButtonWidth;//按鈕間的距離
    float floatPitch = floatButtonDistance+floatButtonWidth;
//    float floatWidth1 = (floatWidth-floatButtonWidth*5-floatButtonDistance*4)/2;//最左側到第一個button的距離
    CGRect frame1 = self.buttonHome.frame;//因為不移動Home及Office,以他們為定位,frame1 是第三個按鈕位置
    
    switch (mode)
    {
        case MapSettingMenuModeButtonsAll:
        {
            [self.buttonHome setHidden:NO];
            [self.buttonOffice setHidden:NO];
            
            CGRect frameStart = frame1;
            frameStart.origin.x = frame1.origin.x - 2*floatPitch;
            self.buttonStart.frame = frameStart;
            
            CGRect frameEnd = frame1;
            frameEnd.origin.x = frame1.origin.x - floatPitch;
            self.buttonEnd.frame = frameEnd;
            
            CGRect frameCollection = frame1;
            frameCollection.origin.x = frame1.origin.x + 2* floatPitch;
            self.buttonAddCollection.frame = frameCollection;
        }
            break;

        case MapSettingMenuModeBottonsWithoutHomeAndOffice:
        {
            [self.buttonHome setHidden:YES];
            [self.buttonOffice setHidden:YES];
            
            CGRect frameStart = frame1;
            frameStart.origin.x = frame1.origin.x - floatPitch;
            self.buttonStart.frame = frameStart;
            
            self.buttonEnd.frame = frame1;
            
            CGRect frameCollection = frame1;
            frameCollection.origin.x = frame1.origin.x + 1* floatPitch;
            self.buttonAddCollection.frame = frameCollection;
        }
            break;
            
        default:
            break;
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark - IBAction
- (IBAction)actBtnSearchTouchUpInside:(id)sender
{
    [self actQueryDate];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (!self.viewControllerRoutePlan)
    {
        self.viewControllerRoutePlan = [[RoutePlanViewController alloc]initWithNibName:@"RoutePlanViewController" bundle:nil];
    }
    
    if(buttonIndex == 0)
        return;
    NSLog(@"%@", self.dictionarySelectedLocation);
    self.viewFunctionBtns.hidden = YES;
    if([selectType isEqualToString:@"start"]) {
        NSString * strAddress = [self.viewControllerRoutePlan actPointToAddressLat:[[self.dictionarySelectedLocation objectForKey:@"Lat"] floatValue] actPointToAddressLon:[[self.dictionarySelectedLocation objectForKey:@"Lon"] floatValue]];
        [self.dictionarySelectedLocation setObject:strAddress forKey:@"Address"];
        [self.dictionarySelectedLocation setObject:strAddress forKey:@"Name"];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(mapSetting:setLocation:toStart:)])
        {
            [self.delegate mapSetting:self setLocation:self.dictionarySelectedLocation toStart:YES];
        }
    } else if ([selectType isEqualToString:@"end"]) {
        NSString * strAddress = [self.viewControllerRoutePlan actPointToAddressLat:[[self.dictionarySelectedLocation objectForKey:@"Lat"] floatValue] actPointToAddressLon:[[self.dictionarySelectedLocation objectForKey:@"Lon"] floatValue]];
        [self.dictionarySelectedLocation setObject:strAddress forKey:@"Address"];
        [self.dictionarySelectedLocation setObject:strAddress forKey:@"Name"];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(mapSetting:setLocation:toStart:)])
        {
            [self.delegate mapSetting:self setLocation:self.dictionarySelectedLocation toStart:NO];
        }
    } else if ([selectType isEqualToString:@"home"]) {
        NSString * strAddress = [self.viewControllerRoutePlan actPointToAddressLat:[[self.dictionarySelectedLocation objectForKey:@"Lat"] floatValue] actPointToAddressLon:[[self.dictionarySelectedLocation objectForKey:@"Lon"] floatValue]];
        
        [self.dictionarySelectedLocation setObject:strAddress forKey:@"Address"];
        [self.dictionarySelectedLocation setObject:@"null" forKey:@"Class"];
        [self.dictionarySelectedLocation setObject:@"null" forKey:@"ClassId"];
        [self.dictionarySelectedLocation setObject:@"回家" forKey:@"Name"];
        [DataManager addRoutePlanFromDictionary:self.dictionarySelectedLocation];
    } else if ([selectType isEqualToString:@"office"]) {
        NSString * strAddress = [self.viewControllerRoutePlan actPointToAddressLat:[[self.dictionarySelectedLocation objectForKey:@"Lat"] floatValue] actPointToAddressLon:[[self.dictionarySelectedLocation objectForKey:@"Lon"] floatValue]];
        
        [self.dictionarySelectedLocation setObject:strAddress forKey:@"Address"];
        [self.dictionarySelectedLocation setObject:@"null" forKey:@"Class"];
        [self.dictionarySelectedLocation setObject:@"null" forKey:@"ClassId"];
        [self.dictionarySelectedLocation setObject:@"公司" forKey:@"Name"];
        [DataManager addRoutePlanFromDictionary:self.dictionarySelectedLocation];
    }
    NSLog(@"__%@",self.dictionarySelectedLocation);
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)actBtnFunctionTouchUpInside:(UIButton*)sender
{
    NSString *type = sender.titleLabel.text;
    NSString *stringSelect;
    if([type isEqualToString:@"start"]) {
        selectType = @"start";
        stringSelect = @"起點";
    } else if ([type isEqualToString:@"end"]) {
        selectType = @"end";
        stringSelect = @"迄點";
    } else if ([type isEqualToString:@"home"]) {
        selectType = @"home";
        stringSelect = @"回家地點";
    } else if ([type isEqualToString:@"office"]) {
        selectType = @"office";
        stringSelect = @"公司地點";
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"是否設定此地點為%@",stringSelect] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"確定", nil];
    [alertView show];

}


#pragma mark - Method
-(void)actSetView
{
    if (!self.viewControllerMap)
    {
        self.viewControllerMap = [[MapViewController alloc]initWithNibName:@"MapViewController" bundle:nil];
        [self addChildViewController:self.viewControllerMap];
        self.viewControllerMap.delegate = self;
        self.viewControllerMap.view.frame = self.viewMap.bounds;
        [self.viewMap addSubview:self.viewControllerMap.view];
    }
}
-(void)actQueryDate
{
    if (self.textFieldSearch.text.length>0)
    {
        [self.textFieldSearch resignFirstResponder];
        NSString * stringKeyWords = self.textFieldSearch.text;
        NSString * stringUrl = [NSString stringWithFormat:APIGoogleKeyWords,stringKeyWords];
        [appDelegate.requestManager addRequestWithKey:@"GoogleSpot" andUrl:stringUrl byType:RequestDataTypeJson];
    }
}
#pragma mark - SlideMenu UIControl
-(void)slideViewController:(id)viewController didTappedBackButton:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextField delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.textFieldSearch)
    {
        [self actQueryDate];
    }
    [textField resignFirstResponder];
    return YES;
}
#pragma mark - MapViewController Deleage
-(void)mapView:(UIViewController *)mapView didUpdateUserLocation:(CLLocationCoordinate2D)userLocation
{
    if (!boolGetUserLocationNotFirst)
    {
        boolGetUserLocationNotFirst = YES;
        [self.viewControllerMap actChangeLocationToCoordinate:userLocation];
    }
}

-(void)mapView:(UIViewController *)mapView didSelectAnnotation:(id<MKAnnotation>)annotation
{
    self.dictionarySelectedLocation = [NSMutableDictionary new];
    [self.dictionarySelectedLocation setObject:[NSString stringWithFormat:@"%f",annotation.coordinate.latitude] forKey:@"Lat"];
    [self.dictionarySelectedLocation setObject:[NSString stringWithFormat:@"%f",annotation.coordinate.longitude] forKey:@"Lon"];
    [self.dictionarySelectedLocation setObject:annotation.title forKey:@"Name"];
}

-(void)mapView:(UIViewController *)mapView didTappedOnCoordinate:(CLLocationCoordinate2D)coordinateTapped
{
    NSString * stringLat = [NSString stringWithFormat:@"%.6f",coordinateTapped.latitude];
    NSString * stringLon = [NSString stringWithFormat:@"%.6f",coordinateTapped.longitude];
    
    NSString * stringTitle = [NSString stringWithFormat:@"Lat:%@,Lon:%@",stringLat,stringLon];
    Annotation * annotationOne = [[Annotation alloc]initWithTitle:stringTitle subTitle:stringTitle coordinate:CLLocationCoordinate2DMake(stringLat.floatValue, stringLon.floatValue)];
    [self.viewControllerMap actPutOnMapViewWithAnnotations:@[annotationOne]];
    [self.viewControllerMap actSelectAnnotation:annotationOne];
    self.viewFunctionBtns.hidden = NO;
}
-(CLLocationCoordinate2D)mapViewDefultCenter
{
    CLLocationCoordinate2D coodinateDefault = CLLocationCoordinate2DMake(KeyDefaultLat, KeyDefaultLon);
    return coodinateDefault;
}
#pragma mark - requestManager Delegate
-(void)requestManager:(id)requestManager returnJSONSerialization:(NSJSONSerialization *)jsonSerialization withKey:(NSString *)key
{
    if ([key isEqualToString:@"GoogleSpot"])
    {
        dictionaryGoogleResult = (NSDictionary*)jsonSerialization;
        if (!self.dictionarySelectedLocation)
        {
            self.dictionarySelectedLocation = [NSMutableDictionary new];
        }
        else
        {
            [self.dictionarySelectedLocation removeAllObjects];
        }
        //取得name
        NSString * stringName = [[[[[dictionaryGoogleResult objectForKey:@"results"] objectAtIndex:0] objectForKey:@"address_components"]objectAtIndex:0]objectForKey:@"short_name"];
        
        //取得座標
        NSDictionary * dictionaryLocation = [[[[dictionaryGoogleResult objectForKey:@"results"]objectAtIndex:0] objectForKey:@"geometry"]objectForKey:@"location"];
        
        //加入dictionary
        if (stringName && dictionaryLocation)
        {
           
            Annotation * annotationOne = [[Annotation alloc]initWithTitle:stringName subTitle:nil coordinate:CLLocationCoordinate2DMake([[dictionaryLocation objectForKey:@"lat"]floatValue], [[dictionaryLocation objectForKey:@"lng"]floatValue])];
            
            [self.viewControllerMap actPutOnMapViewWithAnnotations:@[annotationOne]];
            [self.viewControllerMap actSelectAnnotation:annotationOne];
            self.viewFunctionBtns.hidden = NO;
        }
        else
        {
            NSLog(@"google API decoded failed");
        }
    }
}
-(void)requestManagerStartActivityIndicator
{
    
}
-(void)requestManagerStopActivityIndicator
{
    
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.textFieldSearch resignFirstResponder];
}
@end
