//
//  NotificationDetailViewController.m
//  i84Taoyuan
//
//  Created by TMS_APPLE on 2014/8/15.
//  Copyright (c) 2014年 TMS. All rights reserved.
//

#import "NotificationDetailViewController.h"
#import "AppDelegate.h"

//http://117.56.151.240/Taoyuan/NewAPI/API/UploadOrderStop.ashx?Did=test&Path=1&Stop=879&Goback=1&Stime=09:00&Etime=10:00&Btime=5&IsOpen=1&Phone=test&Day=3&isAction=1

#define APIUpdateNotification @"%@/NewAPI/API/UploadOrderStop.ashx?Did=%@&Phone=%@&Path=%@&Stop=%@&GoBack=%@&Stime=%@&Etime=%@&Btime=%@&IsOpen=%@&Day=%@&isAction=%@"

@interface NotificationDetailViewController ()
<
SlideViewControllerUIControl
,RequestManagerDelegate
,UIPickerViewDataSource
,UIPickerViewDelegate
>

@property (strong, nonatomic) IBOutlet UIView *viewDatePicker;
@property (strong, nonatomic) IBOutlet UIView *viewPicker;
@property (strong, nonatomic) IBOutlet UIPickerView *pickerView;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;

@property (strong, nonatomic) IBOutlet UITextField *textFieldStartTime;
@property (strong, nonatomic) IBOutlet UITextField *textFieldEndTime;
@property (strong, nonatomic) IBOutlet UITextField *textFieldAlarmTime;
@property (strong, nonatomic) IBOutlet UISwitch *switchNotification;
@property (strong, nonatomic) IBOutlet UILabel *labelRouteName;
@property (strong, nonatomic) IBOutlet UILabel *labelStopName;
@property (strong, nonatomic) IBOutlet UILabel *labelToward;
@property (strong, nonatomic) IBOutlet UIView *viewBtnWeek;


- (IBAction)actBtnPickerMinuteOKTouchUpInside:(id)sender;
- (IBAction)actBtnDatePickerOKTouchUpInside:(id)sender;
- (IBAction)actBtnWeekTouchUpInside:(id)sender;
- (IBAction)actBtnOKTouchUpInside:(id)sender;

@end

@implementation NotificationDetailViewController

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
    // Do any additional setup after loading the view from its nib.
    [self actSetView];
}
- (void)viewWillAppear:(BOOL)animated
{
//    self.viewControllerList.delegate = self;
    appDelegate.viewControllerSlide.UIControl = self;
    appDelegate.requestManager.delegate = self;
//    appDelegate.updateTimer.delegate = self;
    [self actLoadIBOutletFromDictionary];
}
-(void)viewWillDisappear:(BOOL)animated
{
//    self.viewControllerList.delegate = nil;
    
    if (appDelegate.viewControllerSlide.UIControl == self)
    {
        appDelegate.viewControllerSlide.UIControl = nil;
    }
    if (appDelegate.requestManager.delegate == self)
    {
        appDelegate.requestManager.delegate = nil;
    }
//    if (appDelegate.updateTimer.delegate == self)
//    {
//        appDelegate.updateTimer.delegate = nil;
//    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)actSetView
{
    self.textFieldStartTime.inputView = self.viewDatePicker;
    self.textFieldEndTime.inputView = self.viewDatePicker;
    self.textFieldAlarmTime.inputView = self.viewPicker;
}
-(void)actLoadIBOutletFromDictionary
{
    
    NSString * stringStartTime = [self.selectedStop objectForKey:@"Stime"];
    NSString * stringEndTime = [self.selectedStop objectForKey:@"Etime"];
    NSString * stringAlarmTime = [self.selectedStop objectForKey:@"Btime"];
    NSString * stringWeek = [self.selectedStop objectForKey:@"Days"];
    NSString * stringIsOpen = [self.selectedStop objectForKey:@"isOpen"];
    
    
    if (!stringStartTime)
    {
        stringStartTime = @"07:00";
    }
    if (!stringEndTime)
    {
        stringEndTime = @"09:00";
    }
    if (!stringAlarmTime)
    {
        stringAlarmTime = @"5";
    }
    if (!stringWeek)
    {
        stringWeek = @"";
    }
    if (!stringIsOpen)
    {
        stringIsOpen = @"0";
    }
    
    [self.labelRouteName setText:[self.selectedStop objectForKey:@"PathName"]];
    [self.labelStopName setText:[self.selectedStop objectForKey:@"StopName"]];
    
//    NSInteger integerToward = [[self.selectedStop objectForKey:@"GoBack"] intValue];
//    [self.labelToward setText:integerToward?[NSString stringWithFormat:@"返程:往%@",[self.selectedStop objectForKey:@"Dept"]]:[NSString stringWithFormat:@"去程:往%@",[self.selectedStop objectForKey:@"Dest"]]];
    
    [self.labelToward setText:[[self.selectedStop objectForKey:@"GoBack"] intValue]?[self.selectedStop objectForKey:@"Dept"]:[self.selectedStop objectForKey:@"Dest"]];
    [self.switchNotification setOn:[stringIsOpen intValue]];
    [self.textFieldStartTime setText:[self actGetTimeStringFromDate:[self actGetTimeDateFromString:stringStartTime]]];
    [self.textFieldEndTime setText:[self actGetTimeStringFromDate:[self actGetTimeDateFromString:stringEndTime]]];
    [self.textFieldAlarmTime setText:stringAlarmTime];
    
    //設定星期的按鈕全不選
    for (UIButton* buttonDay in self.viewBtnWeek.subviews)
    {
        buttonDay.selected = NO;
    }
    //字串中出現的星期的按鈕則設為seleted
    for (int i = 1; i<=7; i++)
    {
        NSRange range = [stringWeek rangeOfString:[NSString stringWithFormat:@"%d",i]];
        if (range.length > 0)
        {
            for (UIButton* buttonDay in self.viewBtnWeek.subviews)
            {
                if(buttonDay.tag==i)
                {
                    buttonDay.selected = YES;
                    break;
                }
            }
        }
    }
    
}
-(void)actSetDictionaryFromIBOutlet
{

        [self.selectedStop setObject:self.textFieldAlarmTime.text forKey:@"Btime"];
    [self.selectedStop setObject:self.textFieldStartTime.text forKey:@"Stime"];
    [self.selectedStop setObject:self.textFieldEndTime.text forKey:@"Etime"];
    [self.selectedStop setObject:[NSString stringWithFormat:@"%d",self.switchNotification.on] forKey:@"isOpen"];
    NSMutableString * stringWeek = [NSMutableString new];
    for (UIButton* buttonDay in self.viewBtnWeek.subviews)
    {
        if (buttonDay.selected == YES)
        {
            [stringWeek appendString:[NSString stringWithFormat:@"%ld|",(long)buttonDay.tag]];
        }
    }
    [self.selectedStop setObject:stringWeek forKey:@"Days"];
}


- (IBAction)actBtnWeekTouchUpInside:(UIButton*)sender
{
    [sender setSelected:!sender.selected];
}

+(NSString*)urlStringFromDictionary:(NSDictionary*)stop byType:(NotificationUpdateType)type
{
    //預設值
    if (!appDelegate.token)
    {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"推播註冊失敗" message:@"無法使用到站提醒功能" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return nil;
    }
    NSString * stringRouteId = [stop objectForKey:@"PathId"];
    NSString * stringStopId = [stop objectForKey:@"StopId"];
    NSString * stringToward = [stop objectForKey:@"GoBack"];
    
    NSString * stringStartTime = [stop objectForKey:@"Stime"];
    NSString * stringEndTime = [stop objectForKey:@"Etime"];
    NSString * stringAlarmTime = [stop objectForKey:@"Btime"];
    NSString * stringWeek = [stop objectForKey:@"Days"];
    NSString * stringIsOpen = [stop objectForKey:@"isOpen"];
    
    NSString * stringType = [NSString stringWithFormat:@"%d",type];
    
    
    if (!stringStartTime)
    {
        stringStartTime = @"07:00";
    }
    if (!stringEndTime)
    {
        stringEndTime = @"09:00";
    }
    if (!stringAlarmTime)
    {
        stringAlarmTime = @"5";
    }
    if (!stringWeek)
    {
        stringWeek = @"";
    }
    if (!stringIsOpen)
    {
        stringIsOpen = @"0";
    }
    
    
    NSString * stringUrl = [NSString stringWithFormat:APIUpdateNotification,
                            APIServer,
                            appDelegate.token,
                            @"iPhone",
                            stringRouteId,
                            stringStopId,
                            stringToward,
                            stringStartTime,
                            stringEndTime,
                            stringAlarmTime,
                            stringIsOpen,
                            stringWeek,
                            stringType
                            ];
    
    return stringUrl;
}
- (IBAction)actBtnOKTouchUpInside:(UIButton*)sender
{
    if (sender.tag)
    {
        [self actSetDictionaryFromIBOutlet];
        NSString *stringUrl = [NotificationDetailViewController urlStringFromDictionary:self.selectedStop byType:NotificationUpdateTypeUpdate];
        [appDelegate.requestManager addRequestWithKey:@"UpdateNotification" andUrl:stringUrl byType:RequestDataTypeString];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (IBAction)actBtnPickerMinuteOKTouchUpInside:(UIButton*)sender
{
    [self.textFieldAlarmTime resignFirstResponder];
}

- (IBAction)actBtnDatePickerOKTouchUpInside:(UIButton*)sender
{
    UITextField * textFieldSelect;
    if ([self.textFieldStartTime isFirstResponder])
    {
        textFieldSelect = self.textFieldStartTime;
    }
    else
        if ([self.textFieldEndTime isFirstResponder])
        {
            textFieldSelect = self.textFieldEndTime;
        }
    [textFieldSelect setText:[self actGetTimeStringFromDate:self.datePicker.date]];
    [textFieldSelect resignFirstResponder];
}
-(NSString *)actGetTimeStringFromDate:(NSDate*)date
{
    NSDateFormatter * formatterShow = [NSDateFormatter new];
    [formatterShow setDateFormat:@"HH:mm"];
    
   return [formatterShow stringFromDate:date];
}
-(NSDate *)actGetTimeDateFromString:(NSString*)string
{
    NSDateFormatter * formatterShow = [NSDateFormatter new];
    [formatterShow setDateFormat:@"HH:mm"];
    
    return [formatterShow dateFromString:string];
}
#pragma mark - UIPickerView delegate & datasource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 60;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [NSString stringWithFormat:@"%ld",(long)row+1];
}
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [self.textFieldAlarmTime setText:[NSString stringWithFormat:@"%ld",(long)row+1]];
    NSLog(@"select %@",[NSString stringWithFormat:@"%ld",(long)row+1]);
}
#pragma mark - slide uicontrol
-(void)slideViewController:(id)viewController didTappedBackButton:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - requestManager Delegate
-(void)requestManager:(id)requestManager returnString:(NSString *)stringResponse withKey:(NSString *)key
{
//    if ([key isEqualToString:@""])
//    {
    if ([stringResponse isEqualToString:@"1"]||[stringResponse isEqualToString:@"ok"])
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"儲存失敗" message:@"請重新輸入" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
//    }
}
@end
