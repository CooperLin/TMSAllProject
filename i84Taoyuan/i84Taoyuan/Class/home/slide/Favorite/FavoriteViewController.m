//
//  FavoriteViewController.m
//  i84GaoXiong
//
//  Created by TMS_APPLE on 2014/7/31.
//  Copyright (c) 2014年 TMS. All rights reserved.
//

#import "FavoriteViewController.h"
//#import "UpdateTimer.h"
//#import "RequestManager.h"
#import "DataManager+Favorite.h"
#import "ListViewController.h"
#import "AppDelegate.h"
#import "FavoriteCell.h"

//http://117.56.151.240/Taoyuan/NewAPI/API/GetArrivaltime.ashx?pathid=1&stopid=879&goback=1
#define APIArriveTime @"%@/NewAPI/API/GetArrivaltime.ashx?pathid=%@&stopid=%@&goback=%@"

@interface FavoriteViewController ()
<
ListViewControllerDelegate
,RequestManagerDelegate
,UpdateTimerDelegate
,SlideViewControllerUIControl
>
{
    NSInteger integerUpdateTime;
    NSMutableDictionary * dictionaryStopTime;
    UIButton *getStatusBtn;
}
@property (strong, nonatomic) IBOutlet UIView *viewBody;
@property (strong, nonatomic) IBOutlet UILabel *labelUpdateTime;
@property (strong, nonatomic) ListViewController * viewControllerList;
@property (strong, nonatomic) NSMutableArray * arrayFavorites;

- (IBAction)actBtnUpdateTouchUpInside:(id)sender;

@end

@implementation FavoriteViewController

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
}
- (void)viewWillAppear:(BOOL)animated
{
    [self actSetView];
    self.viewControllerList.delegate = self;
    appDelegate.viewControllerSlide.UIControl = self;
    appDelegate.requestManager.delegate = self;
    appDelegate.updateTimer.delegate = self;
    [self actLoadFavorites];

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
    if (appDelegate.updateTimer.delegate == self)
    {
        appDelegate.updateTimer.delegate = nil;
    }
    /*
     edit Cooper 2015/08/17
     buglist0807 桃園第二項
     在離開此畫面時將barItem 的按鈕狀態回復為unselected
     */
    if([getStatusBtn isSelected]){
        [self.viewControllerList.tableViewResult setEditing:NO animated:YES];
        [getStatusBtn setSelected:NO];
    }
}
-(void)actSetView
{
    if (!self.viewControllerList)
    {
        self.viewControllerList = [[ListViewController alloc]initWithNibName:@"ListViewController" bundle:nil];
//        self.viewControllerList.delegate = self;
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

- (IBAction)actBtnUpdateTouchUpInside:(id)sender
{
    [self actQueryData];
}
#pragma mark - updateTimer delegate
-(void)updateTimerTick:(NSUInteger)updateTime
{
    if (integerUpdateTime % ValueUpdateTime == 0)
    {
        [self actQueryData];
    }
    [self.labelUpdateTime setText:[NSString stringWithFormat:@"%ld",(long)integerUpdateTime++]];
}
#pragma mark - requestManager Delegate
-(void)requestManager:(id)requestManager returnJSONSerialization:(NSJSONSerialization *)jsonSerialization withKey:(NSString *)key
{
    if ([key hasPrefix:@"Favorite"])
    {
        
        NSString * stringIndex = [[key componentsSeparatedByString:@"-"]objectAtIndex:1];
        if (!dictionaryStopTime)
        {
            dictionaryStopTime = [NSMutableDictionary new];
        }
        [dictionaryStopTime setObject:(NSDictionary*)jsonSerialization forKey:stringIndex];
        [self.viewControllerList reloadListData];
        integerUpdateTime = 1;
    }
}
-(void)requestManagerStopActivityIndicator
{
    [self.viewControllerList reloadListData];
}
#pragma mark - ListViewController Delegate
-(NSInteger)listViewController:(UIViewController *)viewController numberOfRowsInSection:(NSInteger)section
{
    return self.arrayFavorites.count;
}

-(UITableViewCell *)listViewController:(ListViewController *)viewController cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FavoriteCell * cell = [viewController.tableViewResult dequeueReusableCellWithIdentifier:@"FavoriteCell"];
    if (cell == nil)
    {
        NSArray * nib = [[NSBundle mainBundle] loadNibNamed:@"FavoriteCell" owner:self options:nil];
        cell = (FavoriteCell *)[nib objectAtIndex:0];
    }
    NSDictionary * dictionaryFavorite = [self.arrayFavorites objectAtIndex:indexPath.row];
    
    NSString * stringRouteName = [dictionaryFavorite objectForKey:KeyRouteName];
    cell.labelRouteName.text = stringRouteName;
    NSString * stringStopName = [dictionaryFavorite objectForKey:KeyStopName];
    cell.labelStopName.text = stringStopName;
    NSString * stringToward = [dictionaryFavorite objectForKey:KeyToward];
    NSInteger integerToward = [stringToward integerValue];
    
    cell.labelToward.text = [NSString stringWithFormat:@"往:%@",[dictionaryFavorite objectForKey:@"Dest"]];
    
    NSDictionary * dictionaryTimeInfo = [dictionaryStopTime objectForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
    NSString * stringTimeCheck;
    NSString * stringArriveTime = [NSMutableString new];
//    if ([[dictionaryTimeInfo objectForKey:KeyRouteID]isEqualToString:[dictionaryFavorite objectForKey:KeyRouteID]]
//         && [[dictionaryTimeInfo objectForKey:KeyStopID]isEqualToString:[dictionaryFavorite objectForKey:KeyStopID]]
//        && [[dictionaryTimeInfo objectForKey:KeyToward]isEqualToString:[dictionaryFavorite objectForKey:KeyToward]])
//    {
    if (dictionaryTimeInfo)
    {
        stringArriveTime = [NSMutableString stringWithString:[dictionaryTimeInfo objectForKey:@"Time"]];
    }

    if ([stringArriveTime rangeOfString:@":"].length == 0 && stringArriveTime.integerValue > 0)
    {
        stringArriveTime = [stringArriveTime stringByAppendingString:@"分"];
    }

    
    [cell.labelArriveTime setText:stringArriveTime];
//    }
//    if (stringArriveTime)
//    {
//        cell.labelArriveTime.text = [NSString stringWithFormat:@"%@%@",stringArriveTime,stringTimeCheck.intValue>=0?@"分":@""];
//    }
//    else
//    {
//        cell.labelArriveTime.text = @"讀取中";
//    }
    return cell;
}
-(void)listViewController:(ListViewController *)viewController didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
-(void)listViewController:(ListViewController *)viewController commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        DataManagerResult result = [DataManager favoriteDeleteFromDictionary:[self.arrayFavorites objectAtIndex:indexPath.row]];
        if (result == DataManagerResultSuccess)
        {
            [self.arrayFavorites removeObjectAtIndex:indexPath.row];
            [viewController.tableViewResult deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
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
    /*
     edit Cooper 2015/08/17
     buglist0807 桃園第二項
     在離開此畫面時將barItem 的按鈕狀態回復為unselected
     */
    getStatusBtn = button;
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
    label.text = @"我的最愛";
}
-(void)actQueryData
{
    if (self.arrayFavorites.count)
    {
        for (int i = 0;i<self.arrayFavorites.count;i++)
        {
            NSDictionary * dictionaryStop = [self.arrayFavorites objectAtIndex:i];
            NSString * stringStopId = [dictionaryStop objectForKey:KeyStopID];
            NSString * stringRouteId = [dictionaryStop objectForKey:KeyRouteID];
            NSString * stringToward = [dictionaryStop objectForKey:KeyToward];
            NSString * stringUrl = [NSString stringWithFormat:APIArriveTime,APIServer,stringRouteId,stringStopId,stringToward];
            NSString * stringKey = [NSString stringWithFormat:@"FavoriteTime-%d",i];
            [appDelegate.requestManager addRequestWithKey:stringKey andUrl:stringUrl byType:RequestDataTypeJson];
        }
    }
}
-(void)actLoadFavorites
{
    self.arrayFavorites = [DataManager favoriteGetData];
    [self actReloadTable];
    if (self.arrayFavorites.count > 0)
    {
        [self actQueryData];
    }
}
-(void)actReloadTable
{
    [self.viewControllerList reloadListData];
}
@end
