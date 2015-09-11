//
//  NotificationViewController.m
//  i84Taoyuan
//
//  Created by TMS_APPLE on 2014/9/21.
//  Copyright (c) 2014年 TMS. All rights reserved.
//

#import "NotificationViewController.h"
//#import "RequestManager.h"
#import "DataManager+Favorite.h"
#import "ListViewController.h"
#import "AppDelegate.h"
#import "NotificationCell.h"
#import "NotificationDetailViewController.h"

//http://tourguide.tainan.gov.tw/NewTNBusAPI/API/GetOrderStop.ashx?Did=test&Phone=test
//http://122.146.229.210/ksbusn/newAPI/GetOrderStop.ashx?Did=iOS1234567&Phone=iPhone
#define APIGetNotification @"%@/NewAPI/API/GetOrderStop.ashx?Did=%@&Phone=iPhone"

@interface NotificationViewController ()
<
ListViewControllerDelegate
,RequestManagerDelegate
,SlideViewControllerUIControl
,UIAlertViewDelegate
>
{
    NSDictionary * dictionaryDelete;
    NSIndexPath * indexPathDelete;
}
@property (strong, nonatomic) IBOutlet UIView *viewBody;
@property (strong, nonatomic) ListViewController * viewControllerList;
@property (strong, nonatomic) NSMutableArray * arrayNotifications;
@property (strong, nonatomic) NotificationDetailViewController * viewControllerNotificationDetail;

@end

@implementation NotificationViewController

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
}
- (void)viewWillAppear:(BOOL)animated
{
    self.viewControllerList.delegate = self;
    appDelegate.viewControllerSlide.UIControl = self;
    appDelegate.requestManager.delegate = self;
    [self actQueryData];
}
-(void)viewWillDisappear:(BOOL)animated
{
    self.viewControllerList.delegate = nil;
    
    if (appDelegate.viewControllerSlide.UIControl == self)
    {
        appDelegate.viewControllerSlide.UIControl = nil;
    }
    if (appDelegate.requestManager.delegate == self)
    {
        appDelegate.requestManager.delegate = nil;
    }
    
}
-(void)actSetView
{
    if (!self.viewControllerList)
    {
        self.viewControllerList = [[ListViewController alloc]initWithNibName:@"ListViewController" bundle:nil];
        self.viewControllerList.delegate = self;
        [self addChildViewController:self.viewControllerList];
        self.viewControllerList.view.frame = self.viewBody.bounds;
        [self.viewBody addSubview:self.viewControllerList.view];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - requestManager Delegate
-(void)requestManager:(id)requestManager returnJSONSerialization:(NSJSONSerialization *)jsonSerialization withKey:(NSString *)key
{
    if ([key isEqualToString:@"NotificationList"])
    {
        if ([jsonSerialization isKindOfClass:[NSArray class]])
        {
            
            self.arrayNotifications = [NSMutableArray arrayWithArray:(NSArray*)jsonSerialization];
            [self.viewControllerList reloadListData];
        }
    }
}
-(void)requestManager:(id)requestManager returnString:(NSString *)stringResponse withKey:(NSString *)key
{
    if ([key isEqualToString:@"NotificationDelete"])
    {
        [self.arrayNotifications removeObjectAtIndex:indexPathDelete.row];
        [self.viewControllerList.tableViewResult deleteRowsAtIndexPaths:@[indexPathDelete] withRowAnimation:UITableViewRowAnimationFade];
    }
}
#pragma mark - ListViewController Delegate
-(NSInteger)listViewController:(UIViewController *)viewController numberOfRowsInSection:(NSInteger)section
{
    return self.arrayNotifications.count;
}
-(CGFloat)listViewController:(UIViewController *)viewController heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 110;
}
-(UITableViewCell *)listViewController:(ListViewController *)viewController cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NotificationCell * cell = [viewController.tableViewResult dequeueReusableCellWithIdentifier:@"NotificationCell"];
    if (cell == nil)
    {
        NSArray * nib = [[NSBundle mainBundle] loadNibNamed:@"NotificationCell" owner:self options:nil];
        cell = (NotificationCell *)[nib objectAtIndex:0];
    }
    NSDictionary * dictionaryNotification = [self.arrayNotifications objectAtIndex:indexPath.row];
    cell.labelRouteName.text = [dictionaryNotification objectForKey:@"PathName"];
    cell.labelStopName.text = [dictionaryNotification objectForKey:@"StopName"];
    NSInteger integerToward = [[dictionaryNotification objectForKey:@"GoBack"] integerValue];
//    cell.labelToward.text = [NSString stringWithFormat:@"往:%@",[dictionaryFavorite objectForKey:integerToward?@"Dest":@"Dept"]];
    cell.labelToward.text = integerToward?@"返程":@"去程";
    
    NSArray * arrayWeek = [[dictionaryNotification objectForKey:@"Days"]componentsSeparatedByString:@"|"];
    if (arrayWeek.count > 1)
    {
        NSMutableString * stringWeek = [NSMutableString new];
        for (int i = 0; i<arrayWeek.count-1; i++)
        {
            if (i > 0)
            {
                [stringWeek appendString:@","];
            }
            else
            {
                [stringWeek appendString:@"提醒週期:"];
            }
            NSInteger integerDay = [[arrayWeek objectAtIndex:i] integerValue];
            NSString * stringDay;
            switch (integerDay)
            {
                case 1:
                    stringDay = @"週一";
                    break;
                case 2:
                    stringDay = @"週二";
                    break;
                case 3:
                    stringDay = @"週三";
                    break;
                case 4:
                    stringDay = @"週四";
                    break;
                case 5:
                    stringDay = @"週五";
                    break;
                case 6:
                    stringDay = @"週六";
                    break;
                case 7:
                    stringDay = @"週日";
                    break;
                    
                default:
                    break;
            }
            [stringWeek appendString:stringDay];
        }
        cell.labelWeek.text = stringWeek;
    }
    cell.labelTime.text = [NSString stringWithFormat:@"提醒時間:%@-%@,到站%@分前提醒",[dictionaryNotification objectForKey:@"Stime"],[dictionaryNotification objectForKey:@"Etime"],[dictionaryNotification objectForKey:@"Btime"]];
    
    NSString * stringImageName;
    if ([[dictionaryNotification objectForKey:@"isOpen"] intValue])
    {
        stringImageName = @"push_enable";
    }
    else
    {
        stringImageName = @"push_disable";
    }
    cell.imageViewSwich.image = [UIImage imageNamed:stringImageName];
    
    return cell;
    
}
-(void)listViewController:(UIViewController *)viewController didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.viewControllerNotificationDetail)
    {
        self.viewControllerNotificationDetail = [[NotificationDetailViewController alloc]initWithNibName:@"NotificationDetailViewController" bundle:nil];
    }
    self.viewControllerNotificationDetail.selectedStop = [NSMutableDictionary dictionaryWithDictionary:[self.arrayNotifications objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:self.viewControllerNotificationDetail animated:YES];
}
-(void)listViewController:(UIViewController *)viewController commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        dictionaryDelete = [self.arrayNotifications objectAtIndex:[indexPath row]];
        indexPathDelete = indexPath;
        NSString * stringRouteName = [dictionaryDelete objectForKey:@"PathName"];
        NSString * stringStopName = [dictionaryDelete objectForKey:@"StopName"];
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"確定刪除 %@[%@]?",stringRouteName,stringStopName] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"確定刪除", nil];
        alert.tag = 678;
        [alert show];
    }
}
-(void)actQueryData
{
    if (!appDelegate.token)
    {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"推播註冊失敗" message:@"無法使用到站提醒功能" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    NSString * stringUrl = [NSString stringWithFormat:APIGetNotification,APIServer,appDelegate.token];
    [appDelegate.requestManager addRequestWithKey:@"NotificationList" andUrl:stringUrl byType:RequestDataTypeJson];
}
#pragma mark - SlideMenu UIControl
-(void)slideViewController:(id)viewController setAdditionalButton:(UIButton *)button
{
    [button setImage:[UIImage imageNamed:@"slide_edit"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"slide_finish"] forState:UIControlStateSelected];

}
-(void)slideViewController:(id)viewController didTappedAdditionalButton:(UIButton *)button
{
    [button setSelected:![button isSelected]];
    
    if ([button isSelected])
    {
        [self.viewControllerList.tableViewResult setEditing:YES animated:YES];
    }
    else
    {
        [self.viewControllerList.tableViewResult setEditing:NO animated:YES];
    }
}
-(void)slideViewController:(id)viewController setTitleLabel:(UILabel *)label
{
    label.text = @"到站提醒";
}
#pragma mark - UIAlertView Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 678 && buttonIndex == 1)
    {
        NSString * stringUrl = [NotificationDetailViewController urlStringFromDictionary:dictionaryDelete byType:NotificationUpdateTypeDelete];
        [appDelegate.requestManager addRequestWithKey:@"NotificationDelete" andUrl:stringUrl byType:RequestDataTypeString];
    }
}
@end
