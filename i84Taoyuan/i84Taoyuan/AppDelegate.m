//
//  AppDelegate.m
//  i84Taoyuan
//
//  Created by TMS_APPLE on 2014/9/1.
//  Copyright (c) 2014年 TMS. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

#import "AppDelegate.h"
#import "GDataXMLNode.h"

#define APIRoutes @"%@/NewAPI/API/GetPath.ashx"

//接受Toke即上傳
//http://117.56.151.240/Taoyuan/NewAPI/API/UploadToken.ashx?did=test&type=test
//#define APIUploadToken @"%@/NewAPI/API/UploadToken.ashx?did=%@&type=iPhone"
#define APIIndustry @"http://117.56.151.239/xmlbus3/StaticData/GetProvider.xml"
#define APIUploadToken @"http://192.168.6.189/TYBus/API/UploadToken?DeviceID=%@&Token=%@&Type=iPhone"


@interface AppDelegate ()
<
RequestManagerDelegate
>

@property (strong,nonatomic) UIViewController *viewControllerRoot;
@property (strong,nonatomic) UIView *viewBase;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    self.viewControllerRoot = [UIViewController new];
    
    [self.window setRootViewController:self.viewControllerRoot];
    self.viewBase = [UIView new];
    CGRect frameNew = self.viewControllerRoot.view.bounds;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = paths.firstObject;
    NSLog(@"%@",basePath);
    
    if (IOSVersion >= 7.0)
    {
        frameNew.size.height -= 20;
        frameNew.origin.y += 20;
    }
    self.viewBase.frame = frameNew;
    
    [self.viewControllerRoot.view addSubview:self.viewBase];
    
    [self actGoToHome];
    
    self.requestManager = [[RequestManager alloc]init];
    self.requestManager.delegate = self;
    
    NSString * stringURL = [NSString stringWithFormat:APIRoutes,APIServer];
    
    if (![DataManager routeCheckUpdatedToday])
    {
        [self.requestManager addRequestWithKey:@"Routes" andUrl:stringURL byType:RequestDataTypeJson];
    }
    
    self.updateTimer = [[UpdateTimer alloc]initWithAlarmTime:ValueUpdateTime];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }

 //   [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];

    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}
//call by home buttons
-(void)actGoToFunction:(SlideFunctionType)type
{
    if (!self.viewControllerSlide)
    {
        self.viewControllerSlide = [[SlideViewController alloc]initWithNibName:@"SlideViewController" bundle:nil];
    }
    self.viewControllerSlide.delegate = self;
    
//    appDelegate.functionType = type;
    [self changeViewController:self.viewControllerSlide];
    [self.viewControllerSlide changeFunction:type];
}
-(void)actGoToHome
{
    if (!self.viewControllerHome)
    {
        self.viewControllerHome = [[HomeViewController alloc]initWithNibName:@"HomeViewController" bundle:nil];
    }
    self.viewControllerHome.delegate = self;
    
    [self changeViewController:self.viewControllerHome];
}
-(void)changeViewController:(UIViewController*)viewController
{
//    /* 一般ViewController中使用
    if (![self.viewControllerRoot.childViewControllers containsObject:viewController])
    {
        if (self.viewControllerRoot.childViewControllers.count > 0)
        {
            for (id viewController in self.viewControllerRoot.childViewControllers)
            {
                [((UIViewController*)viewController).view removeFromSuperview];
                [viewController removeFromParentViewController];
            }
        }
        [self.viewControllerRoot addChildViewController:viewController];
        ((UIViewController*)viewController).view.frame = self.viewBase.bounds;
        [self.viewBase addSubview:((UIViewController*)viewController).view];
        
        for (id viewController in self.viewControllerRoot.childViewControllers)
        {
            NSLog(@"\nviewController subViewControllers:\n%@",viewController);
        }
    }

}
//功能切換(slideMenu下的功能)
-(void)changeFunction:(SlideFunctionType)type
{
    [self.viewControllerSlide changeFunction:type];
}
#pragma mark - Home delegate
-(void)homeViewController:(id)viewController goToFunction:(int)type
{
    [self actGoToFunction:type];
}
#pragma mark - Slide delegate
-(void)slideViewControllerBackToHome
{
    [self actGoToHome];
}
#pragma mark - requestManager delegate
-(void)requestManager:(id)requestManager returnJSONSerialization:(NSJSONSerialization *)jsonSerialization withKey:(NSString *)key
{
    if ([key isEqualToString:@"Routes"])
    {
        NSArray * arrayFronJson = (NSArray*)jsonSerialization;
        [DataManager routeUpdateTableFromArray:arrayFronJson];
    }
}
-(void)requestManager:(id)requestManager returnString:(NSString *)stringResponse withKey:(NSString *)key
{
    if ([key isEqualToString:@"UploadToken"])
    {
        if ([stringResponse isEqualToString:@"1"])
        {
            NSLog(@"SUCCESS!!   Token %@ Uploaded",self.token);
        }
    }
    if([@"TokenUpload" isEqualToString:key])
    {
        if ([stringResponse isEqualToString:@"1"])
        {
            NSLog(@"SUCCESS!!   Token %@ Uploaded",self.token);
        }
    }
}
#pragma mark notification
- (void) application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString* newToken = [deviceToken description];
	newToken = [newToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
	newToken = [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    self.token = newToken;
    
    UIDevice *deviceId = [[UIDevice alloc] init];
    NSString *uuid = deviceId.identifierForVendor.UUIDString;
    
    NSString * stringUrl = [NSString stringWithFormat:APIUploadToken,uuid,self.token];
    
    [self.requestManager addRequestWithKey:@"TokenUpload" andUrl:stringUrl byType:RequestDataTypeString];
    
 	NSLog(@"Notification uuid %@ Token is: %@", uuid, self.token);
//    if(PushManagerObj == nil)
//    {
//        PushManagerObj = [[PushManager alloc] initWithToken:newToken];
//    }
}
- (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"Received notification: %@", userInfo);
}
- (void) application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Failed to get token, error: %@",error);
    self.token = @"test";
//    if(PushManagerObj == nil && [PushManager GetToken] != nil)
//    {
//        PushManagerObj = [[PushManager alloc] initWithToken:[PushManager GetToken]];
//    }
}

//訊息視窗
- (void)showAlertView:(NSString *)title setMessage:(NSString *)message setMessage:(NSString *)cancel
{
    UIAlertView * alertView;
    alertView = [[UIAlertView alloc]initWithTitle:title message:message delegate:nil cancelButtonTitle:cancel otherButtonTitles:nil];
    [alertView show];
}


/////////////////////////////////////////////

#pragma mark notification
//-(void)getIndustryData
//{
//    NSURL * url = [NSURL URLWithString:APIIndustry];
//    // 網路請求位置
//    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
//    // 請求方法默認Get
//    [request setHTTPMethod:@"GET"];
//    // 2.連接服務器
//    // Response对象，用来得到返回后的数据，比如，用statusCode==200 来判断返回正常
//    NSHTTPURLResponse *response;
//    NSError * error = nil;
//    // 3. 返回数据
//    NSData * data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
////     NSData转化NSString  用的是实例方法
////    NSString * stringMessage = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
////    NSLog(@"stringMessage_____%@",stringMessage);
//    
////    self.IndustryArray = [NSMutableArray new];
//    NSXMLParser* xmlRead = [[NSXMLParser alloc] initWithData:data];//初始化NSXMLParser对象
//    [xmlRead setDelegate:self];//设置NSXMLParser对象的解析方法代理
//    [xmlRead parse];
//        
////    NSString *urlString=@"sfdsfhttp://www.baidu.com";
////    //NSRegularExpression类里面调用表达的方法需要传递一个NSError的参数。下面定义一个
////    
////    NSError * error;
//    //http+:[^\\s]* 这个表达式是检测一个网址的。
////    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"http+:[^\\s]*" options:0 error:&error];
//    
////    if (regex != nil) {
////        
////         NSTextCheckingResult *firstMatch=[regex firstMatchInString:urlString options:0 range:NSMakeRange(0, [urlString length])];
////        
////        if (firstMatch) {
////            NSRange resultRange = [firstMatch rangeAtIndex:0]; //等同于 firstMatch.range --- 相匹配的范围
////            //从urlString当中截取数据
////            
////            NSString *result=[urlString substringWithRange:resultRange];
////            
////            //输出结果
////            
////            NSLog(@"這是我要看的%@",result);
////            
////        }
////    }
//    
//}


@end
