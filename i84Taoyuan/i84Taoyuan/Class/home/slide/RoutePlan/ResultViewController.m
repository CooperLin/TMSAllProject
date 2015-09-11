//
//  ResultViewController.m
//  i84Taoyuan
//
//  Created by TMS_APPLE on 2014/8/26.
//  Copyright (c) 2014年 TMS. All rights reserved.
//

#import "ResultViewController.h"
#import "AppDelegate.h"
#import "ListViewController.h"
#import "PlanResultCell.h"
#import "PlanDetailSpotTableViewCell.h"
#import "PlanDetailTableViewCell.h"

//typedef enum
//{
//    PlanResultCellTypeNormal = 0
//    ,PlanResultCellTypeSpot = 2
//    ,PlanResultCellTypePath = 1
//    ,PlanResultCellTypeStart = 3
//    ,PlanResultCellTypeEnd = 4
//}PlanResultCellType;
//http://117.56.151.240/Taoyuan/WebService/Service.asmx/JsonTravelPlan?SPx=121.145903&SPy=24.913714&EPx=121.211861&EPy=24.960950&Mode=2&source=w&SName=%E6%A1%83%E5%9C%92%E7%81%AB%E8%BB%8A%E7%AB%99&EName=%E4%B8%AD%E5%A3%A2%E7%81%AB%E8%BB%8A%E7%AB%99
#define APIPlanResult @"%@/WebService/Service.asmx/JsonTravelPlan?SPy=%@&SPx=%@&EPy=%@&EPx=%@&Lang=Cht&Mode=2&source=i&SName=%@&EName=%@"

@interface ResultViewController ()
<
RequestManagerDelegate
,ListViewControllerDelegate
,SlideViewControllerUIControl
>
{
    NSArray * arrayResult;
    NSInteger integerRevealIndex;//第幾個Cell展開
    NSInteger integerRevealNumber;//展開中Cell數量
}
@property (strong, nonatomic) IBOutlet UILabel * labelStart;
@property (strong, nonatomic) IBOutlet UILabel * labelEnd;
@property (strong, nonatomic) IBOutlet UIView * viewList;
@property (strong, nonatomic) ListViewController * viewControllerList;
//@property (strong, nonatomic)

@end

@implementation ResultViewController

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
}
- (void)viewWillAppear:(BOOL)animated
{
    [self actSetView];
    appDelegate.viewControllerSlide.UIControl = self;
    appDelegate.requestManager.delegate = self;
    self.viewControllerList.delegate = self;
    
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

}
-(void)viewDidDisappear:(BOOL)animated
{
    integerRevealIndex = 0;
    integerRevealNumber = 0;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)actSetView
{
//    self.labelTitle.text = [NSString stringWithFormat:@"%@ -> %@",[self.dictionaryLocationStart objectForKey:@"Name"],[self.dictionaryLocationEnd objectForKey:@"Name"]];
    self.labelStart.text = [self.dictionaryLocationStart objectForKey:@"Name"];
    self.labelEnd.text = [self.dictionaryLocationEnd objectForKey:@"Name"];

    if(!self.viewControllerList)
    {
        self.viewControllerList = [[ListViewController alloc]initWithNibName:@"ListViewController" bundle:nil];
        [self addChildViewController:self.viewControllerList];
        self.viewControllerList.view.frame = self.viewList.bounds;
        [self.viewList addSubview:self.viewControllerList.view];
    }
    
}
-(void)actQueryData
{
//    arrayResult = @[];
//    [self.viewControllerList reloadListData];
//    NSString * stringUrl = @"http://tourguide.tainan.gov.tw/NewTNBusAPI/API/TravelPlan.ashx?SLat=22.995378&SLon=120.209302&ELat=22.97753&ELon=120.19412";
    NSString * stringUrl = [NSString stringWithFormat:APIPlanResult,
                            APIServer,
                            [self.dictionaryLocationStart objectForKey:@"Lat"],
                            [self.dictionaryLocationStart objectForKey:@"Lon"],
                            [self.dictionaryLocationEnd objectForKey:@"Lat"],
                            [self.dictionaryLocationEnd objectForKey:@"Lon"],
                            [self.dictionaryLocationStart objectForKey:@"Name"],
                            [self.dictionaryLocationEnd objectForKey:@"Name"]
                            ];
    [appDelegate.requestManager addRequestWithKey:@"PlanResult" andUrl:stringUrl byType:RequestDataTypeJson];
}
#pragma mark - SlideMenu UIControl
-(void)slideViewController:(id)viewController didTappedBackButton:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - RequestManager Delegate
-(void)requestManager:(id)requestManager returnJSONSerialization:(NSJSONSerialization *)jsonSerialization withKey:(NSString *)key
{
    //api 送上去後，會回來一個binary 檔案，但是回不到這邊就結束了
    if ([key isEqualToString:@"PlanResult"])
    {
        id checkMsg = [((NSArray*)jsonSerialization) objectAtIndex:0];
        if ([checkMsg isKindOfClass:[NSString class]])
        {
            NSString * stringCheck = (NSString*)checkMsg;
            if ([stringCheck hasPrefix:@"err"])
            {
                NSString * stringTitle = @"查無資料";
                NSString * stringMessage = @"請再試一次";
                if ([stringCheck isEqualToString:@"err03"])
                {
                    stringTitle = @"查無資料";
                    stringMessage = @"請重新輸入起迄點";
                }
                else
                    if ([stringCheck isEqualToString:@"err03"])
                    {
                        stringTitle = @"參數錯誤";
                        stringMessage = @"請再試一次";
                    }
                UIAlertView * alert = [[UIAlertView alloc]initWithTitle:stringTitle message:stringMessage delegate:nil cancelButtonTitle:@"確認" otherButtonTitles:nil];
                [alert show];
                [self.navigationController popViewControllerAnimated:YES];
                return;
            }
        }
        arrayResult = (NSArray *)jsonSerialization;
        [self.viewControllerList reloadListData];
    }

}
#pragma mark - ListViewController delegate
-(NSInteger)listViewController:(UIViewController *)viewController numberOfRowsInSection:(NSInteger)section
{
    return arrayResult.count+integerRevealNumber;
}
-(CGFloat)listViewController:(UIViewController *)viewController heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat floatHeight = 105.0;//一般Cell高
    if (integerRevealNumber > 0)
    {
        NSInteger integerTmp  = indexPath.row - integerRevealIndex;

        if (integerTmp > 0 && integerTmp <= integerRevealNumber)
        {
            if (integerTmp%2 == 0)
            {
                floatHeight = 60.0;
            }
            else
            {
                floatHeight = 40.0;
            }
        }
    }
    return floatHeight;
}
-(UITableViewCell *)listViewController:(ListViewController *)viewController cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //detail
    NSInteger integerTmp  = indexPath.row - integerRevealIndex;
    
    //判斷是否在detail list
    if (integerTmp > 0 && integerTmp <= integerRevealNumber)
    {
        NSDictionary * dictionaryIndex = [arrayResult objectAtIndex:integerRevealIndex];
        if (integerTmp%2 == 0)
        {
            //第2,4,6...
            PlanDetailTableViewCell * cell = [viewController.tableViewResult dequeueReusableCellWithIdentifier:@"PlanDetailCell"];
            if (cell == nil)
            {
                NSArray * nib = [[NSBundle mainBundle] loadNibNamed:@"PlanDetailTableViewCell" owner:self options:nil];
                cell = (PlanDetailTableViewCell *)[nib objectAtIndex:0];
            }
            
            NSArray * stringDescriptions = [[dictionaryIndex objectForKey:@"Plan"]objectAtIndex:integerTmp-2];
            NSString * stringDescription1 = [stringDescriptions objectAtIndex:0];
//            stringDescription1 = [stringDescription1 stringByReplacingOccurrencesOfString:@"{end}" withString:[self.dictionaryLocationEnd objectForKey:@"Name"]];
//            stringDescription1 = [stringDescription1 stringByReplacingOccurrencesOfString:@"{start}" withString:[self.dictionaryLocationStart objectForKey:@"Name"]];
            cell.labelDesciption1.text = stringDescription1;
            cell.labelDesciption2.text = [stringDescriptions objectAtIndex:1];

            //用來決定前方圖示
            NSString * stringType = [[dictionaryIndex objectForKey:@"TransType"]objectAtIndex:(integerTmp-1)/2];
            
            //圖示
            NSString * stringImageName = nil;

            if ([stringType isEqualToString:@"walk"])
            {
                stringImageName = @"plan_type_walk";
            }
            else
                if ([stringType isEqualToString:@"bus"])
                {
                    stringImageName = @"plan_type_bus";
                }
                else
                    if ([stringType isEqualToString:@"TRA"])
                    {
                        stringImageName = @"plan_type_train";
                    }
            
            cell.imageViewType.image = [UIImage imageNamed:stringImageName];
            
            return cell;

        }
        else
        {
            //第1,3,5..
            PlanDetailSpotTableViewCell * cell = [viewController.tableViewResult dequeueReusableCellWithIdentifier:@"PlanDetailSpotCell"];
            if (cell == nil)
            {
                NSArray * nib = [[NSBundle mainBundle] loadNibNamed:@"PlanDetailSpotTableViewCell" owner:self options:nil];
                cell = (PlanDetailSpotTableViewCell *)[nib objectAtIndex:0];
            }


            NSString * stringImageName = nil;
            NSString * stringName = @"";
            
            if (integerTmp == 1)
            {
                //Start
                stringImageName = @"plan_detail_start";
                stringName = [self.dictionaryLocationStart objectForKey:@"Name"];
            }
            else
                if (integerTmp == integerRevealNumber)
                {
                    //End
                    stringImageName = @"plan_detail_end";
                    stringName = [self.dictionaryLocationEnd objectForKey:@"Name"];

                }
                else
                {
                    stringImageName = @"plan_detail_through";
                    stringName = [[[dictionaryIndex objectForKey:@"Plan"]objectAtIndex:integerTmp-2]objectAtIndex:0];
                }
            cell.imageViewSpot.image = [UIImage imageNamed:stringImageName];
            cell.labelSpotName.text = stringName;
            return cell;

        }
    }
    else
    {
        PlanResultCell * cell = [viewController.tableViewResult dequeueReusableCellWithIdentifier:@"PlanResultCell"];
        if (cell == nil)
        {
            NSArray * nib = [[NSBundle mainBundle] loadNibNamed:@"PlanResultCell" owner:self options:nil];
            cell = (PlanResultCell *)[nib objectAtIndex:0];
        }
        NSInteger integerIndex = indexPath.row > integerRevealIndex ? (indexPath.row-integerRevealNumber): indexPath.row;
        
        NSDictionary * dicionaryIndex = [arrayResult objectAtIndex:integerIndex];
        cell.labelPlan.text = [NSString stringWithFormat:@"方案%ld",(long)(integerIndex+1)];
        NSString * stringTravelTime = [dicionaryIndex objectForKey:@"Time"];
        cell.labelTravelTime.text = stringTravelTime.length?[NSString stringWithFormat:@"約%@分",stringTravelTime]:@"";
        NSString * stringArriveTime = [dicionaryIndex objectForKey:@"ArrTime"];
        cell.labelArriveTime.text = stringArriveTime.length?[NSString stringWithFormat:@"預計%@抵達",stringArriveTime]:@"";
        NSString * stringPlanStart = [dicionaryIndex objectForKey:@"Start"];
        NSString * stringPlanEnd = [dicionaryIndex objectForKey:@"End"];
        cell.labelDescription.text = [NSString stringWithFormat:@"%@-%@",stringPlanStart,stringPlanEnd];
        
        NSArray * arrayTransType = [dicionaryIndex objectForKey:@"TransType"];
        NSArray * arrayCarInfo = [dicionaryIndex objectForKey:@"TransCarInfo"];
        if(arrayTransType.count == 5) {
            [cell.viewPlanSubView addSubview:cell.viewPlanNum5];
            for(int i = 0;i < arrayTransType.count;i++){
                NSString * stringType = [[dicionaryIndex objectForKey:@"TransType"] objectAtIndex:i];
                NSString * stringImageName = nil;
                if ([stringType isEqualToString:@"walk"])
                    stringImageName = @"plan_type_walk";
                else if ([stringType isEqualToString:@"bus"])
                    stringImageName = @"plan_type_bus";
                else if ([stringType isEqualToString:@"TRA"])
                    stringImageName = @"plan_type_train";
                if(i == 0)
                    cell.imgPlanStart5.image = [UIImage imageNamed:stringImageName];
                else if(i == 1)
                    cell.imgPlanChange5_1.image = [UIImage imageNamed:stringImageName];
                else if(i == 2)
                    cell.imgPlanChange5_2.image = [UIImage imageNamed:stringImageName];
                else if(i == 3)
                    cell.imgPlanChange5_3.image = [UIImage imageNamed:stringImageName];
                else if(i == 4)
                    cell.imgPlanEnd5.image = [UIImage imageNamed:stringImageName];
            }
            cell.labelPlanChange5_1.text = [arrayCarInfo objectAtIndex:0];
            cell.labelPlanChange5_2.text = [arrayCarInfo objectAtIndex:1];
        } else if(arrayTransType.count == 3) {
            [cell.viewPlanSubView addSubview:cell.viewPlanNum3];
            for(int i = 0;i < arrayTransType.count;i++){
                NSString * stringType = [[dicionaryIndex objectForKey:@"TransType"] objectAtIndex:i];
                NSString * stringImageName = nil;
                if ([stringType isEqualToString:@"walk"])
                    stringImageName = @"plan_type_walk";
                else if ([stringType isEqualToString:@"bus"])
                    stringImageName = @"plan_type_bus";
                else if ([stringType isEqualToString:@"TRA"])
                    stringImageName = @"plan_type_train";
                if(i == 0)
                    cell.imgPlanStart3.image = [UIImage imageNamed:stringImageName];
                else if(i == 1)
                    cell.imgPlanChange3.image = [UIImage imageNamed:stringImageName];
                else if(i == 2)
                    cell.imgPlanEnd3.image = [UIImage imageNamed:stringImageName];
            }
            cell.labelPlanChange3.text = [arrayCarInfo objectAtIndex:0];
        } else if(arrayTransType.count == 1) {
            [cell.viewPlanSubView addSubview:cell.viewPlanNum3];
            cell.imgPlanChange3.image = [UIImage imageNamed:@"plan_type_walk"];
            cell.labelArrow3_1.hidden = YES;
            cell.labelArrow3_2.hidden = YES;
        }
        
        return cell;
    }
}

-(void)listViewController:(UIViewController *)viewController didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < integerRevealIndex)
    {
        integerRevealIndex = indexPath.row;
        integerRevealNumber = [[[arrayResult objectAtIndex:indexPath.row]objectForKey:@"Plan"] count] + 2;
    }
    else
        if (indexPath.row > integerRevealIndex+integerRevealNumber)
        {
            integerRevealIndex = indexPath.row - integerRevealNumber;
            integerRevealNumber = [[[arrayResult objectAtIndex:indexPath.row - integerRevealNumber]objectForKey:@"Plan"] count] + 2;
        }
        else
            if (indexPath.row == integerRevealIndex)
            {
                if(integerRevealNumber>0)
                {
                    integerRevealNumber = 0;
                }
                else
                {
                    integerRevealNumber = [[[arrayResult objectAtIndex:indexPath.row]objectForKey:@"Plan"] count] + 2;
                }
            }
    [self.viewControllerList reloadListData];
}

@end
