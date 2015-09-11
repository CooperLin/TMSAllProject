//
//  TimeListViewController.m
//  i84Taoyuan
//
//  Created by TMS_APPLE on 2014/9/1.
//  Copyright (c) 2014年 TMS. All rights reserved.
//

#import "TimeListViewController.h"
#import "ListViewController.h"
#import "AppDelegate.h"
#import "SlideViewController.h"
#import "RequestManager.h"
#import "TimeListTableViewCell.h"
#import "webViewController.h"

#define APIStaticRoute @"http://117.56.151.239/tybus/GetTimeTable1.php?useXno=1&route=%@"


@interface TimeListViewController ()
<
SlideViewControllerUIControl
,RequestManagerDelegate
>
@property (strong, nonatomic) webViewController * viewControllerWeb;
//@property (strong, nonatomic) NSArray * arrayTimeList;
@end

@implementation TimeListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(id)init
{
    self = [super init];
    if (self)
    {
        if (!self.viewControllerWeb)
        {
            self.viewControllerWeb = [[webViewController alloc]initWithNibName:@"webViewController" bundle:nil];

        }
        self.viewControllerWeb.view.frame = self.view.bounds;
        [self.view addSubview:self.viewControllerWeb.view];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

}
-(void)viewWillAppear:(BOOL)animated
{
    NSLog(@"TimeList viewWillAppear");
    appDelegate.viewControllerSlide.UIControl = self;
    [self.viewControllerWeb.webViewMain loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:APIStaticRoute,[self.selectedRoute objectForKey:@"PathId"]]]]];

}
-(void)viewWillDisappear:(BOOL)animated
{
    if (appDelegate.viewControllerSlide.UIControl == self)
    {
        appDelegate.viewControllerSlide.UIControl = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - slide uicontrol protocol
-(void)slideViewController:(id)viewController didTappedBackButton:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(UIColor*)colorWithAlpha:(CGFloat)alpha R:(NSString*)red G:(NSString*)green B:(NSString*)blue
{
    UIColor * color = [UIColor colorWithRed:[self getDecimalFromHexadecimal:red]/255.0 green:[self getDecimalFromHexadecimal:green]/255.0 blue:[self getDecimalFromHexadecimal:blue]/255.0 alpha:alpha];
    return color;
}
-(NSUInteger)getDecimalFromHexadecimal:(NSString*)string
{
    unsigned result = 0;
    
//    if ([string hasPrefix:@"#"])
//    {
        NSScanner *scanner = [NSScanner scannerWithString:string];
//        [scanner setScanLocation:1]; // bypass '#' character
        [scanner scanHexInt:&result];
//    }
//    else
//    {
//        NSLog(@"Hexadecimal Style : \"#00001\"");
//    }
    return result;
}

@end
