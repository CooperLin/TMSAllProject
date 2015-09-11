//
//  SearchBusViewController.m
//  i84Taoyuan
//
//  Created by TMS_APPLE on 2014/9/1.
//  Copyright (c) 2014年 ＴＭＳ 景翊科技. All rights reserved.
//

#import "SearchBusViewController.h"
#import "GDataXMLNode.h"
#import "ShareTools.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "AppDelegate.h"
#import "DataManager+Route.h"
#import "SearchBusTableViewCell.h"
#import "busDynamicViewController.h"

@interface SearchBusViewController ()
<
SlideViewControllerUIControl
>
{
    NSMutableArray * arrayTableviewRoutes;
    NSInteger intSelectedProvider;
    NSString * stringProviderID;
    NSInteger intQueryFailCount;
    NSString * stringFilter;
}
@property (strong ,nonatomic) NSMutableArray * arrayRoutes;
@property (strong ,nonatomic) busDynamicViewController * viewControllerBusDynamic;
@end

@implementation SearchBusViewController

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

-(void)viewWillAppear:(BOOL)animated
{
    appDelegate.viewControllerSlide.UIControl = self;
    [self actQueryData];
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
}

-(void)actQueryData
{
    self.arrayRoutes = [DataManager routeGetData];
    [self actGetRoutes];
}

#pragma mark - setting
-(void)actGetRoutes
{
//    [NSThread detachNewThreadSelector:@selector(startActivityIndicator) toTarget:self withObject:nil];
//    NSString * stringProviderTmp = self.labelProvider.text;
    NSMutableArray * arrayToBeFiltered;
    NSMutableArray * arrayFiltered = [NSMutableArray new];
    NSString * stringLabelNow = self.labelInput.text;
        if (!(stringLabelNow.length > 0))
        {
            arrayFiltered = self.arrayRoutes;
        }
        else
        {
            //若 新搜尋 為 舊搜尋 的子字串則從上次結果路線中搜尋，若不是字字串則搜尋全部路線
            if (!stringFilter)
            {
                stringFilter = @"";
            }
            NSRange range = [stringLabelNow rangeOfString:stringFilter];
            if (range.length > 0)
            {
                arrayToBeFiltered = arrayTableviewRoutes;
            }
            else
            {
                arrayToBeFiltered = self.arrayRoutes;
            }
            stringFilter = stringLabelNow;
            
//            //若搜尋字串有"其他",分開"其他"跟後面的數字
            NSString * stringFilterWord = stringLabelNow;
//            NSString * stringFilterType = nil;
//
//            if ([stringLabelNow hasPrefix:@"其他"])
//            {
//                if (stringFilterWord.length>2)
//                {
//                    stringFilterWord = [stringFilterWord stringByReplacingOccurrencesOfString:@"其他" withString:@""];
//                }
//                else
//                {
//                    stringFilterWord = @"";
//                }
//                
//                stringFilterType = @"其他";
//            }
            
            for (NSDictionary * dictionaryRoute in arrayToBeFiltered)
            {
//                NSInteger integerTypeId = [[dictionaryRoute objectForKey:@"typeid"]integerValue];
//                if (!stringFilterType||integerTypeId<10)
//                {
                    NSString * stringRouteName = [dictionaryRoute objectForKey:KeyRouteName];
                    NSRange range = [stringRouteName rangeOfString:stringFilterWord];
                    if ((range.location == 0 && range.length > 0)||[stringFilterWord isEqualToString:@""])
                    {
                        [arrayFiltered addObject:dictionaryRoute];
                    }
//                }
            }
        }
    arrayTableviewRoutes = arrayFiltered;
    
    [self.tableViewSearch reloadData];
    
//    [NSThread detachNewThreadSelector:@selector(stopActivityIndicator) toTarget:self withObject:nil];
}


#pragma mark - IBAction
- (IBAction)actBtnNumbersTouchUpInside:(UIButton*)sender
{
    //tag 10:數字0 11:客運業者 12:清除
    NSInteger intTag = sender.tag;
    if (intTag == 0)
    {
        if ([sender.titleLabel.text isEqualToString:@"清除"])
        {
            [self.labelInput setText:@""];
        }
        else
        {
            [self.labelInput setText:sender.titleLabel.text];
        }
    }
    else
    {
        if (intTag == 10)
        {
            intTag = 0;
        }
            [self.labelInput setText:[NSString stringWithFormat:@"%@%ld",self.labelInput.text,(long)intTag]];
    }
    if (![self.labelInput.text isEqualToString:stringFilter])
    {
        [self actGetRoutes];
    }
}

#pragma mark - UI control

-(void)stopActivityIndicator
{
    [self.activityIndicator stopAnimating];
    [self.ContentV setUserInteractionEnabled:YES];
}
-(void)startActivityIndicator
{
    [self.ContentV setUserInteractionEnabled:NO];
    [self.activityIndicator startAnimating];
}

#pragma mark - tableview Delegate&DataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrayTableviewRoutes.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //尋找tableview可回收Cell(需注意cell.xib要設定identifier,回收機制才有用)
    SearchBusTableViewCell * cell = (SearchBusTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"SearchBusTableViewCell"];
    
    //若無可回收Cell則由Bundle取得
    if (cell == nil)
    {
        NSArray *nib=[[NSBundle mainBundle]loadNibNamed:@"SearchBusTableViewCell" owner:self options:nil];
        for (id object in nib)
        {
            if ([object isKindOfClass:[SearchBusTableViewCell class]])
            {
                cell = (SearchBusTableViewCell*)object;
                break;
            }
        }
    }
    
    NSDictionary * dictionaryRoute = [arrayTableviewRoutes objectAtIndex:indexPath.row];
    [cell.labelTitle setText:[dictionaryRoute objectForKey:KeyRouteName]];
    [cell.labelDescription setText:[NSString stringWithFormat:@"%@ - %@",[dictionaryRoute objectForKey:KeyRouteDeparture],[dictionaryRoute objectForKey:KeyRouteDestination]]];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * dictionaryRoute = [arrayTableviewRoutes objectAtIndex:indexPath.row];
    
    if (!self.viewControllerBusDynamic)
    {
        self.viewControllerBusDynamic = [[busDynamicViewController alloc]initWithNibName:@"busDynamicViewController" bundle:nil];
    }
    self.viewControllerBusDynamic.selectedRoute = dictionaryRoute;
    [self.navigationController pushViewController:self.viewControllerBusDynamic animated:YES];
}
#pragma mark - SliderViewController UIControl
-(void)slideViewController:(id)viewController setTitleLabel:(UILabel *)label
{
    label.text = @"動態公車";
}



@end
