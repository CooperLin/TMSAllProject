//
//  LocationOptionsViewController.m
//  i84Taoyuan
//
//  Created by TMS_APPLE on 2014/9/25.
//  Copyright (c) 2014年 TMS. All rights reserved.
//

#import "LocationOptionsViewController.h"
#import "AppDelegate.h"
#import "ListViewController.h"
#import "DataManager+RoutePlan.h"


@interface LocationOptionsViewController ()
<
ListViewControllerDelegate
,SlideViewControllerUIControl
,UITextFieldDelegate
>
{
    NSDictionary * dictionarySelectedLocation;
    CGFloat screenWidth;
    CGFloat screenHeight;
}
@property (strong, nonatomic) ListViewController * viewControllerList;
@property (strong, nonatomic) IBOutlet UIButton *buttonStart;
@property (strong, nonatomic) IBOutlet UIButton *buttonEnd;
@property (strong, nonatomic) IBOutlet UIButton *buttonCollection;
@property (strong, nonatomic) IBOutlet UIView *viewList;
@property (strong, nonatomic) IBOutlet UIView *viewFuntionBtns;
@property (strong, nonatomic) IBOutlet UITextField *textFieldSearch;
@property (strong, nonatomic) NSMutableArray * arrayListFiltered;
@property (strong, nonatomic) IBOutlet UIView * searchView;

@property NSInteger isSelectIndex;
@property NSIndexPath *isSelectPath;

- (IBAction)actBtnFunctionTouchUpInside:(id)sender;
- (IBAction)actBtnSearchTouchUpInside:(id)sender;
@end

@implementation LocationOptionsViewController

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
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    screenWidth = screenSize.width;
    screenHeight = screenSize.height;
}
- (void)viewWillAppear:(BOOL)animated
{
    appDelegate.viewControllerSlide.UIControl = self;
    self.viewControllerList.delegate = self;
    
    [self actResetView];
    [self actFliterData];
    
    if (self.collectionMode == 1)
    {
        [self.searchView setHidden:NO];
        [self.viewList setFrame:CGRectMake(0, 40, screenWidth, screenHeight - 108)];
    }
    else
    {
        [self.searchView setHidden:YES];
        [self.viewList setFrame:CGRectMake(0, 0, screenWidth, screenHeight - 90)];
    }

}
-(void)viewWillDisappear:(BOOL)animated
{
    if (appDelegate.viewControllerSlide.UIControl == self)
    {
        appDelegate.viewControllerSlide.UIControl = nil;
    }
    dictionarySelectedLocation = nil;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)actSetView
{
    if (!self.viewControllerList)
    {
        self.viewControllerList = [[ListViewController alloc]initWithNibName:@"ListViewController" bundle:nil];
        [self addChildViewController:self.viewControllerList];
        self.viewControllerList.view.frame = self.viewList.bounds;
        [self.viewList addSubview:self.viewControllerList.view];
    }
}
-(void)actResetView
{
    self.viewFuntionBtns.hidden = YES;
    NSString * stringImageName = nil;
    if (self.collectionMode == 1)
    {
        stringImageName = @"plan_collect_add.png";
    }
    else
    {
        stringImageName = @"plan_collect_delete.png";
    }
    [self.buttonCollection setImage:[UIImage imageNamed:stringImageName] forState:UIControlStateNormal];

}
#pragma mark - SlideMenu UIControl
-(void)slideViewController:(id)viewController didTappedBackButton:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - ListViewController Delegate
-(CGFloat)listViewController:(UIViewController *)viewController heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48;
}
-(NSInteger)listViewController:(UIViewController *)viewController numberOfRowsInSection:(NSInteger)section
{
    return self.arrayListFiltered.count;
}
-(UITableViewCell *)listViewController:(ListViewController *)viewController cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = (UITableViewCell *)[viewController.tableViewResult dequeueReusableCellWithIdentifier:@"LocationCell"];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LocationCell"];
    }
    NSDictionary * dictionaryLocation = [self.arrayListFiltered objectAtIndex:indexPath.row];
    
    NSString * stringName = [dictionaryLocation objectForKey:@"Name"];
    NSString * stringAddress = [dictionaryLocation objectForKey:@"Address"];
    
    if(stringAddress.length > 18){
        stringAddress = [NSString stringWithFormat:@"%@...", stringAddress];
//        stringAddress = [NSString stringWithFormat:@"%@...", [stringAddress substringFromIndex:18]];
    }
    
    NSString * showText = [NSString stringWithFormat:@"%@\n%@", stringName, stringAddress];
    cell.textLabel.text = showText;
    cell.textLabel.font = [UIFont fontWithName:@"Arial" size:14];
    cell.textLabel.numberOfLines = 2;
    cell.textLabel.lineBreakMode = UILineBreakModeCharacterWrap;
    cell.backgroundColor = [UIColor clearColor];
    return cell;
    
//    UITableViewCell * cell = (UITableViewCell *)[viewController.tableViewResult dequeueReusableCellWithIdentifier:@"LocationCell"];
//    UILabel * labelName, * labelAddress;
//    if(cell == nil)
//    {
//        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LocationCell"];
//        labelName = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 360, 20)];
//        labelName.backgroundColor = [UIColor clearColor];
//        labelName.font = [UIFont fontWithName:@"Arial" size:18];
//        labelName.textColor = [UIColor blackColor];
//        labelName.adjustsFontSizeToFitWidth = YES;
//        //当adjustsFontSizeToFitWidth=YES时候，如果文本font要缩小时
//        //baselineAdjustment这个值控制文本的基线位置，只有文本行数为1是有效
//        labelName.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
//        //文本最多行数，为0时没有最大行数限制
//        labelName.numberOfLines = 1;
//        //最小字体，行数为1时有效，默认为0.0
//        labelName.minimumFontSize = 10.0;
//        //文本高亮
//        labelName.highlighted = YES;
//        //文本是否可变
//        labelName.enabled = YES;
//        //是否能与用户交互
//        labelName.userInteractionEnabled = YES;
//        [cell addSubview:labelName];
//        
//        labelAddress = [[UILabel alloc] initWithFrame:CGRectMake(5, 27, 360, 20)];
//        labelAddress.backgroundColor = [UIColor clearColor];
//        labelAddress.font = [UIFont fontWithName:@"Arial" size:16];
//        labelAddress.textColor = [UIColor blackColor];
//        labelAddress.adjustsFontSizeToFitWidth = YES;
//        //当adjustsFontSizeToFitWidth=YES时候，如果文本font要缩小时
//        //baselineAdjustment这个值控制文本的基线位置，只有文本行数为1是有效
//        labelAddress.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
//        //文本最多行数，为0时没有最大行数限制
//        labelAddress.numberOfLines = 1;
//        //最小字体，行数为1时有效，默认为0.0
//        labelAddress.minimumFontSize = 10.0;
//        //文本高亮
//        labelAddress.highlighted = YES;
//        //文本是否可变
//        labelAddress.enabled = YES;
//        //是否能与用户交互
//        labelAddress.userInteractionEnabled = YES;
//        [cell addSubview:labelAddress];
//    }
//    NSDictionary * dictionaryLocation = [self.arrayListFiltered objectAtIndex:indexPath.row];
//    //    NSLog(@"location %@",dictionaryLocation);
//    
//    NSString * stringName = [dictionaryLocation objectForKey:@"Name"];
//    NSString * stringAddress = [dictionaryLocation objectForKey:@"Address"];
//    //    cell.textLabel.text = stringName;
//    cell.backgroundColor = [UIColor clearColor];
//    labelName.text = stringName;
//    labelAddress.text = stringAddress;
}

-(void)listViewController:(UIViewController *)viewController didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.isSelectIndex = [indexPath row];
    self.isSelectPath = indexPath;
    self.viewFuntionBtns.hidden = NO;
    dictionarySelectedLocation = [self.arrayListFiltered objectAtIndex:indexPath.row];
}

- (IBAction)actBtnFunctionTouchUpInside:(UIButton*)sender
{
    if (dictionarySelectedLocation)
    {
        switch (sender.tag)
        {
            case 9://收藏加入或刪除
            {
//                NSString * stringMode;
                DataManagerResult result;
                if (self.collectionMode)
                {
                    //加入
                    result = [DataManager addRoutePlanFromDictionary:dictionarySelectedLocation];
                }
                else
                {
                    //刪除
                    result = [DataManager deleteRoutePlanFromDictionary:dictionarySelectedLocation];
                    if (result == DataManagerResultSuccess)
                    {
                        [self.arrayList removeObjectAtIndex:self.isSelectIndex];
                        [self.viewControllerList.tableViewResult deleteRowsAtIndexPaths:@[self.isSelectPath] withRowAnimation:UITableViewRowAnimationFade];
                    }
                }
            }
                
                break;
                
            default:
            {
                if (self.delegate && [self.delegate respondsToSelector:@selector(locationOptionsViewController:withDictionary:andTarget:)])
                {
                    [self.delegate locationOptionsViewController:self withDictionary:dictionarySelectedLocation andTarget:(LocationOptionsReturnTarget)sender.tag];
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }
                break;
        }
        self.viewFuntionBtns.hidden = YES;
    }
    else
    {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"無法辨識地點" message:@"請先從清單中選擇地點" delegate:nil cancelButtonTitle:@"確認" otherButtonTitles:nil];
        [alert show];
    }

}

- (IBAction)actBtnSearchTouchUpInside:(id)sender
{
    [self actFliterData];
}
-(void)actFliterData
{
    if (!self.textFieldSearch||[self.textFieldSearch.text isEqualToString:@""])
    {
        self.arrayListFiltered = self.arrayList;
    }
    else
    {
        NSMutableArray * arrayFiltered = [NSMutableArray new];
        NSString *stringFiltered = self.textFieldSearch.text;
        for (NSDictionary * dictionarySpot in self.arrayList)
        {
            if ([[dictionarySpot objectForKey:@"Name"]rangeOfString:stringFiltered].length> 0)
            {
                [arrayFiltered addObject:dictionarySpot];
            }
        }
        self.arrayListFiltered = arrayFiltered;
    }
    [self.viewControllerList reloadListData];
}
#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self actBtnSearchTouchUpInside:nil];
    return YES;
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.textFieldSearch resignFirstResponder];
}


@end

