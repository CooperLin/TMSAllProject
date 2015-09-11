//
//  SearchBusViewController2.m
//  i84Taoyuan
//
//  Created by TMS on 2014/11/24.
//  Copyright (c) 2014年 TMS. All rights reserved.
//

#import "SearchBusViewController2.h"
#import "GDataXMLNode.h"
#import "ShareTools.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "AppDelegate.h"
#import "DataManager+Route.h"
#import "SearchBusTableViewCell.h"
#import "busDynamicViewController.h"
#import "IndustryCell.h"
#import "XMLParserObject.h"

#define apiIndustry @"http://117.56.151.239/xmlbus3/StaticData/GetProvider.xml"
//#define apiIndustryAllRoute @"http://117.56.151.239/tybus/GetRoute.php?all=1&lan=ch"
#define apiIndustryAllRoute @"http://ebus.tycg.gov.tw/xmlbus3/StaticData/GetRoute.xml?lang=zh"

#define kDefaultAPICityRoute @"http://ebus.tycg.gov.tw/xmlbus3/StaticData/GetRoute.xml?&lang=zh"
#define KDefaultAPIGZHighwayRoute @"http://ebus.tycg.gov.tw/xmlbus3/StaticData/GetRoute.xml?lang=zh&routetype=gz"


@interface SearchBusViewController2 ()
<
SlideViewControllerUIControl
,UITableViewDataSource
,UITableViewDelegate
,NSXMLParserDelegate
>
{
    NSString * searchIndustryType;
    NSMutableArray * arrayTableviewRoutes;
    NSInteger intSelectedProvider;
    NSString * stringProviderID;
    NSInteger intQueryFailCount;
    NSString * stringFilter;
    NSString * searchRtoue;
    NSArray * arrayCityArea;
    UILabel *label;
}

@property (strong ,nonatomic) NSMutableArray * arrayIndustryRoutes;
@property (strong ,nonatomic) NSMutableArray * arrayIndustry;
@property (strong ,nonatomic) NSMutableArray * arrayRoutes;
@property (strong ,nonatomic) busDynamicViewController * viewControllerBusDynamic;
@property (strong, nonatomic) IBOutlet UIView *viewContainer;
@property (strong, nonatomic) IBOutlet UIView *viewNumberBtns;
@property (strong, nonatomic) IBOutlet UIView *viewCityAreaBtns;
@property (strong, nonatomic) IBOutlet UIView *viewIndustryBtns;

@end

@implementation SearchBusViewController2
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
    arrayCityArea = [NSArray arrayWithObjects:@"桃園",@"中壢",@"平鎮",@"八德",@"楊梅",@"蘆竹",@"大溪",@"龍潭",@"龜山",@"大園",@"觀音",@"新屋",@"復興", nil];
    self.arrayIndustry = [NSMutableArray new];
    self.arrayIndustryRoutes = [NSMutableArray new];
    [self getIndustryData];
    [self getIndustryAllRoute];
}
-(void)viewWillAppear:(BOOL)animated
{
    appDelegate.viewControllerSlide.UIControl = self;
    searchRtoue = @"全部路線";
    [self.labelInput setText:searchRtoue];
    [self actChangeSubView:self.viewNumberBtns];
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
    [self.viewContainer addSubview:subView];
}

-(void)actQueryData
{
    self.arrayRoutes = [DataManager routeGetData];
    [self actGetRoutes];
}
#pragma mark - IBAction
- (IBAction)actBtnNumbersTouchUpInside:(UIButton*)sender
{
    //tag 10:清除 11:免費 12:市區 13:業者 14:公路客運
    NSInteger intTag = sender.tag;
    if(intTag == 10) {
        searchRtoue = @"全部路線";
    } else if(intTag == 11) {
        searchRtoue = @"免費公車";
        [self actChangeSubView:self.viewCityAreaBtns];
    } else if(intTag == 12) {
        searchRtoue = @"市區公車";
    } else if(intTag == 13) {
        searchRtoue = @"業者";
        [self actChangeSubView:self.viewIndustryBtns];
        /*
         edit Cooper 2015/08/11
         桃園維運
         （下方的code 才是）
         */
    } else if(intTag == 14) {
        searchRtoue = @"公路客運";
    } else {
        if(![self isPureNumandCharacters:searchRtoue]){
            searchRtoue = @"";
        }
        if(searchRtoue.length < 5) {
            searchRtoue = [searchRtoue stringByAppendingString:[NSString stringWithFormat: @"%ld", (long)intTag]];
        }
    }
    [self actGetRoutes];
    [self.labelInput setText:searchRtoue];
}

- (IBAction)actBtnCityAreaTouchUpInside:(UIButton*)sender
{
    NSString * searchArea = @"";
    NSInteger intTag = sender.tag;
    if(intTag == -1) {
        searchRtoue = @"全部路線";
        [self actChangeSubView:self.viewNumberBtns];
        [self actGetRoutes];
        [self.labelInput setText:searchRtoue];
    } else {
        searchArea = arrayCityArea[intTag];
        [self actGetFreeRoutes:searchArea];
    }
}

- (IBAction)actBtnIndustryTouchUpInside:(UIButton*)sender
{
    NSInteger intTag = sender.tag;
//    NSLog(@"111___%d", intTag);
    if(intTag == -1) {
        searchRtoue = @"全部路線";
        [self actChangeSubView:self.viewNumberBtns];
        [self actGetRoutes];
        [self.labelInput setText:searchRtoue];
    } else {
        NSMutableArray * arrayFiltered = [NSMutableArray new];
        NSDictionary * dictionaryRoute = [self.arrayIndustry objectAtIndex:intTag];
//        NSLog(@"點到%@", dictionaryRoute);
//        NSLog(@"%@", [dictionaryRoute objectForKey:@"nameZh"]);
        NSString * checkProviderId = [dictionaryRoute objectForKey:@"ID"];
        NSLog(@" -- -- -- %@",self.arrayIndustryRoutes);
        for (NSDictionary * dictionaryRoute in self.arrayIndustryRoutes)
        {
            NSString * ProviderId = [dictionaryRoute objectForKey:@"ProviderId"];
            if ([checkProviderId isEqualToString:ProviderId]){
                [arrayFiltered addObject:dictionaryRoute];
//                NSLog(@"%@",dictionaryRoute);
            }
        }
        arrayTableviewRoutes = arrayFiltered;
        if(arrayTableviewRoutes.count == 0)
            [appDelegate showAlertView:@"提示" setMessage:@"無路線資訊" setMessage:@"確認"];
        [self.tableViewSearch reloadData];
        
    }
}

#pragma mark - setting

-(void)actGetRoutes
{
    NSMutableArray * arrayFiltered = [NSMutableArray new];
    [label removeFromSuperview];
    if([searchRtoue isEqualToString:@"全部路線"]) {
        arrayFiltered = self.arrayRoutes;
    } else if([searchRtoue isEqualToString:@"免費公車"]) {
//        for (NSDictionary * dictionaryRoute in self.arrayRoutes)
//        {
//            NSString * RouteType = [dictionaryRoute objectForKey:KeyRouteType];
//            if ([RouteType isEqualToString:@"免費巴士"])
//                [arrayFiltered addObject:dictionaryRoute];
//        }
        NSURL *url =[NSURL URLWithString:kDefaultAPICityRoute];
        XMLParserObject *parser = [[XMLParserObject alloc] initWithURL:url andKeyType:@"CityRoute"];
        arrayFiltered = parser.aryResult;
    } else if([searchRtoue isEqualToString:@"市區公車"]) {
        NSURL *url =[NSURL URLWithString:kDefaultAPICityRoute];
        XMLParserObject *parser = [[XMLParserObject alloc] initWithURL:url andKeyType:@"RTYRoute"];
        arrayFiltered = parser.aryResult;
        if(arrayFiltered.count == 0)
            [appDelegate showAlertView:@"提示" setMessage:@"無路線資訊" setMessage:@"確認"];

//        for (NSDictionary * dictionaryRoute in self.arrayRoutes)
//        {
        
//            [appDelegate.requestManager addRequestWithKey:@"CityRoute" andUrl:stringUrl byType:RequestDataTypeXML];
//            if([[dictionaryRoute objectForKey:@"PathName"] isEqualToString:@"BR"] ||
//               [[dictionaryRoute objectForKey:@"PathName"] isEqualToString:@"GR"] ||
//               [[dictionaryRoute objectForKey:@"PathName"] isEqualToString:@"GR2"] ||
//               [[dictionaryRoute objectForKey:@"PathName"] isEqualToString:@"1"] ||
//               [[dictionaryRoute objectForKey:@"PathName"] isEqualToString:@"171"]) {
//                [arrayFiltered addObject:dictionaryRoute];
//            }
//            NSString * RouteType = [dictionaryRoute objectForKey:KeyRouteType];
//            if ([RouteType isEqualToString:@"RTY"])
//                [arrayFiltered addObject:dictionaryRoute];
//        }
    } else if([searchRtoue isEqualToString:@"業者"]) {
        arrayFiltered = self.arrayIndustryRoutes;
        
        /*
         edit Cooper 2015/08/11
         桃園維運
         （下方的code 才是）
         */
    } else if([@"公路客運" isEqualToString:searchRtoue]){
        NSURL *url =[NSURL URLWithString:KDefaultAPIGZHighwayRoute];
        XMLParserObject *parser = [[XMLParserObject alloc] initWithURL:url andKeyType:@"HighwayRoute"];
        arrayFiltered = parser.aryResult;
        if(arrayFiltered.count == 0)
            [appDelegate showAlertView:@"提示" setMessage:@"無路線資訊" setMessage:@"確認"];

    } else {
        for (NSDictionary * dictionaryRoute in self.arrayRoutes)
        {
            NSString * stringRouteName = [dictionaryRoute objectForKey:KeyRouteName];
            NSRange range = [stringRouteName rangeOfString:searchRtoue];
            if ((range.location == 0 && range.length > 0)||[searchRtoue isEqualToString:@""])
            {
                [arrayFiltered addObject:dictionaryRoute];
            }
        }
        if(arrayFiltered.count == 0)
            [appDelegate showAlertView:@"提示" setMessage:@"無路線資訊" setMessage:@"確認"];
    }
    
    arrayTableviewRoutes = arrayFiltered;
    label.hidden = YES;
    [self.tableViewSearch reloadData];
}

-(void)actGetFreeRoutes:(NSString *) searchArea
{
    [self.labelInput setText:searchArea];
    NSMutableArray * arrayFiltered = [NSMutableArray new];
    
    for (NSDictionary * dictionaryRoute in self.arrayRoutes)
    {
        NSString * RouteType = [dictionaryRoute objectForKey:KeyRouteType];
        NSString * MasterRouteDesc = [dictionaryRoute objectForKey:KeyMasterRouteDesc];
        
        if ([RouteType isEqualToString:@"免費巴士"] && [MasterRouteDesc isEqualToString:searchArea])
            [arrayFiltered addObject:dictionaryRoute];
    }
    
    arrayTableviewRoutes = arrayFiltered;
    if(arrayTableviewRoutes.count == 0)
        [appDelegate showAlertView:@"提示" setMessage:@"無路線資訊" setMessage:@"確認"];
    [self.tableViewSearch reloadData];
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
    [self.tableViewSearch setSeparatorColor: [UIColor blackColor]];
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
    if([@"市區公車" isEqualToString:searchRtoue]){
        [cell.labelTitle setText:[dictionaryRoute objectForKey:@"nameZh"]];
        [cell.labelDescription setText:[dictionaryRoute objectForKey:@"ddesc"]];
    } else if([@"公路客運" isEqualToString:searchRtoue]){
        [cell.labelTitle setText:[dictionaryRoute objectForKey:@"nameZh"]];
        [cell.labelDescription setText:[dictionaryRoute objectForKey:@"ddesc"]];
    } else if([@"免費公車" isEqualToString:searchRtoue]){
        NSString *str = [dictionaryRoute objectForKey:@"nameZh"];
        if(str.length > 0){
            [cell.labelTitle setText:[dictionaryRoute objectForKey:@"nameZh"]];
            [cell.labelDescription setText:[dictionaryRoute objectForKey:@"ddesc"]];
        }else{
            [cell.labelTitle setText:[dictionaryRoute objectForKey:KeyRouteName]];
            [cell.labelDescription setText:[dictionaryRoute objectForKey:KeyDdesc]];
        }
    } else {
        [cell.labelTitle setText:[dictionaryRoute objectForKey:KeyRouteName]];
        [cell.labelDescription setText:[NSString stringWithFormat:@"%@ - %@",[dictionaryRoute objectForKey:KeyRouteDeparture],[dictionaryRoute objectForKey:KeyRouteDestination]]];
    }
    
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

//判斷字串是否都是數字
- (BOOL)isPureNumandCharacters:(NSString *)string
{
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
    if(string.length > 0)
    {
        return NO;
    }
    return YES;
}

//解析業者
-(void)getIndustryData
{
    searchIndustryType = @"getIndustryData";
    NSURL * url = [NSURL URLWithString:apiIndustry];
    // 網路請求位置
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    // 請求方法默認Get
    [request setHTTPMethod:@"GET"];
    // 2.連接服務器
    // Response对象，用来得到返回后的数据，比如，用statusCode==200 来判断返回正常
    NSHTTPURLResponse *response;
    NSError * error = nil;
    // 3. 返回数据
    NSData * data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSXMLParser* xmlRead = [[NSXMLParser alloc] initWithData:data];//初始化NSXMLParser对象
    [xmlRead setDelegate:self];//设置NSXMLParser对象的解析方法代理
    [xmlRead parse];    
}

//解析所有路線
-(void)getIndustryAllRoute
{
    searchIndustryType = @"getIndustryAllRoute";
    NSURL * url = [NSURL URLWithString:apiIndustryAllRoute];
    // 網路請求位置
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    // 請求方法默認Get
    [request setHTTPMethod:@"GET"];
    // 2.連接服務器
    // Response对象，用来得到返回后的数据，比如，用statusCode==200 来判断返回正常
    NSHTTPURLResponse *response;
    NSError * error = nil;
    // 3. 返回数据
    NSData * data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSXMLParser* xmlRead = [[NSXMLParser alloc] initWithData:data];//初始化NSXMLParser对象
    [xmlRead setDelegate:self];//设置NSXMLParser对象的解析方法代理
    [xmlRead parse];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if([searchIndustryType isEqualToString:@"getIndustryData"]){
        NSMutableDictionary * oneInfo = [NSMutableDictionary new];
        if([elementName isEqualToString: @"Provider"])
        {
            NSInteger * id = [[attributeDict valueForKey:@"ID"]intValue];
            if(id < 11){
                [oneInfo setObject:[attributeDict valueForKey:@"ID"] forKey:@"ID"];
                [oneInfo setObject:[attributeDict valueForKey:@"nameZh"] forKey:@"nameZh"];
                [oneInfo setObject:[attributeDict valueForKey:@"type"] forKey:@"type"];
                [self.arrayIndustry addObject:oneInfo];
            }
        }
//        NSLog(@"11%@", elementName);
    } else {
        NSMutableDictionary * oneInfo = [NSMutableDictionary new];
        if([elementName isEqualToString: @"Route"])
        {
            [oneInfo setObject:[attributeDict valueForKey:@"ID"] forKey:@"PathId"];
            [oneInfo setObject:[attributeDict valueForKey:@"ProviderId"] forKey:@"ProviderId"];
            [oneInfo setObject:[attributeDict valueForKey:@"nameZh"] forKey:@"PathName"];
            [oneInfo setObject:[attributeDict valueForKey:@"gxcode"] forKey:@"gxcode"];
            [oneInfo setObject:[attributeDict valueForKey:@"ddesc"] forKey:@"ddesc"];
            [oneInfo setObject:[attributeDict valueForKey:@"departureZh"] forKey:@"Dept"];
            [oneInfo setObject:[attributeDict valueForKey:@"destinationZh"] forKey:@"Dest"];
            if(!attributeDict[@"RouteType"] || !attributeDict[@"MasterRouteName"] || !attributeDict[@"MasterRouteNo"] || !attributeDict[@"MasterRouteDesc"]) {
                [self.arrayIndustryRoutes addObject:oneInfo];
                return;
            }
            
            [oneInfo setObject:[attributeDict valueForKey:@"RouteType"] forKey:@"RouteType"];
            [oneInfo setObject:[attributeDict valueForKey:@"MasterRouteName"] forKey:@"MasterRouteName"];
            [oneInfo setObject:[attributeDict valueForKey:@"MasterRouteNo"] forKey:@"MasterRouteNo"];
            [oneInfo setObject:[attributeDict valueForKey:@"MasterRouteDesc"] forKey:@"MasterRouteDesc"];
            [self.arrayIndustryRoutes addObject:oneInfo];
        }
    }
    
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
//        NSLog(@"結尾%@",elementName);
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    //    NSLog(@"解析______%@",string);
}

@end
