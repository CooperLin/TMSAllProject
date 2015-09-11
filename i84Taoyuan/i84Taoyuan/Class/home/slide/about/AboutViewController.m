//
//  AboutViewController.m
//  i84-TaichungV2
//
//  Created by ＴＭＳ 景翊科技 on 2014/3/7.
//  Copyright (c) 2014年 ＴＭＳ 景翊科技. All rights reserved.
//

#import "AboutViewController.h"
#import "GDataXMLNode.h"
#import "AboutCell.h"
#import "AppDelegate.h"
#import "ShareTools.h"

@interface AboutViewController ()
<
SlideViewControllerUIControl
>
{
    NSMutableArray * XmlRows;
}

@end
@implementation AboutRow

@synthesize Background;
@synthesize Image;
@synthesize qname;
@synthesize Text;

@end

@implementation AboutViewController
@synthesize ContentV,VersionLbl,AboutTv,AttractionVersionLbl;

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
    [ShareTools setViewToFullScreen:self.view];
    NSDictionary *infoDict=[[NSBundle mainBundle]infoDictionary];
    [VersionLbl setText:[NSString stringWithFormat:@"版本序號:%@  %@",[infoDict objectForKey:@"CFBundleShortVersionString"],[infoDict objectForKey:@"CFBundleVersion"]]];
    [self ReadAboutXml];
    [AboutTv reloadData];
//    CGRect ContentFrame = ContentV.frame;
//    SilderMenu = [[SilderMenuView alloc] initWithFrame:CGRectMake(0, 0, 98, ContentFrame.size.height)];
//    [SilderMenu setSilderDelegate:self];
//    [ContentV addSubview:SilderMenu];
//    [SilderMenu setItemsByPlistName:@"LeftMenu"];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    appDelegate.viewControllerSlide.UIControl = self;
}
-(void)viewWillDisappear:(BOOL)animated
{
    if (appDelegate.viewControllerSlide.UIControl == self)
    {
        appDelegate.viewControllerSlide.UIControl = nil;
    }
}
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    [AttractionVersionLbl setText:[NSString stringWithFormat:@"熱門景點版本:%@",[AttractionManager GetVerStr]]];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(XmlRows == nil)return 0;
    else return [XmlRows count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AboutCell * cell = (AboutCell *)[tableView dequeueReusableCellWithIdentifier:@"AboutCell"];
    if(cell == nil)
    {
        NSArray *nib=[[NSBundle mainBundle]loadNibNamed:@"AboutCell" owner:self options:nil];
        cell = (AboutCell *)[nib objectAtIndex:0];
    }
    AboutRow * oneRow = [XmlRows objectAtIndex:[indexPath row]];
    bool hasimage= NO;
    if(oneRow.Background != nil
       &&[oneRow.Background  length] > 0)
    {
        if([oneRow.Background  compare:@"itembg"] == 0)
            [cell.BgV setBackgroundColor:[[UIColor alloc] initWithRed:1.0 green:0.5 blue:0.0 alpha:0.8]];
        else if([oneRow.Background compare:@"Line"] == 0)
            [cell.BgV setBackgroundColor:[UIColor grayColor]];
        else [cell.BgV setBackgroundColor:[UIColor clearColor]];
        
        [cell.TopLine setHidden:NO];
        [cell.BottomLine setHidden:NO];
    }
    else
    {
        [cell.BgV setBackgroundColor:[UIColor clearColor]];
        [cell.TopLine setHidden:YES];
        [cell.BottomLine setHidden:YES];
    }
    
    if(oneRow.Image != nil
       && [oneRow.Image length] > 0)
    {
        hasimage = YES;
        NSString * ResFile = [[NSBundle mainBundle] pathForResource: oneRow.Image ofType: @"png"];
        [cell.Iv setImage:[[UIImage alloc] initWithContentsOfFile:ResFile]];
    }
    CGRect Frame = cell.TitleLbl.frame;
    Frame.origin.x = hasimage ? 40 : 10;
    Frame.origin.y = 0;
    Frame.size.width = hasimage ? 276: 312;
    
    NSMutableString * TextValue = [[NSMutableString alloc] initWithString: oneRow.Text ? oneRow.Text:@""];
    
    NSRange range = [TextValue rangeOfString:@"[Version]"];
    if(range.length > 0)
    {
        NSDictionary *infoDict=[[NSBundle mainBundle]infoDictionary];
        [TextValue deleteCharactersInRange:range];
        [TextValue insertString:[infoDict objectForKey:@"CFBundleShortVersionString"] atIndex:range.location];
    }
    range = [TextValue rangeOfString:@"[BuildDate]"];
    if(range.length > 0)
    {
        NSDictionary *infoDict=[[NSBundle mainBundle]infoDictionary];
        [TextValue deleteCharactersInRange:range];
        [TextValue insertString:[infoDict objectForKey:@"CFBundleVersion"] atIndex:range.location];
    }
    range = [TextValue rangeOfString:@"[AppName]"];
    if(range.length > 0)
    {
        NSDictionary *infoDict=[[NSBundle mainBundle]infoDictionary];
        [TextValue deleteCharactersInRange:range];
        [TextValue insertString:[infoDict objectForKey:@"CFBundleDisplayName"] atIndex:range.location];
    }
    float rowh  = [self tableView:tableView heightForRowAtIndexPath:indexPath];
    Frame.size.height = rowh;
    
    [cell.TitleLbl setText:TextValue];
    
    cell.TitleLbl.numberOfLines = ceil( rowh / 21);
    [cell.TitleLbl setFrame:Frame];
    
    Frame = cell.frame;
    Frame.size.height = rowh;
    [cell setFrame:Frame];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float rowh  = 1.0f;
    AboutRow * oneRow = [XmlRows objectAtIndex:[indexPath row]];
    
    bool hasimage= NO;
    
    if(oneRow.Image != nil
       && [oneRow.Image length] > 0)
        hasimage = YES;
    CGRect Frame;
    Frame.origin.x = hasimage ? 40 : 4;
    Frame.size.width = hasimage ? 276: 312;
    NSString * TextValue = oneRow.Text ? oneRow.Text:@"";
    
    CGSize maximumLabelSize = CGSizeMake(Frame.size.width,300);
    
    CGSize expectedLabelSize = [TextValue sizeWithFont:[UIFont boldSystemFontOfSize:17.0f] constrainedToSize:maximumLabelSize lineBreakMode:UILineBreakModeTailTruncation];
    rowh = expectedLabelSize.height < rowh ? rowh:expectedLabelSize.height;
    
    return rowh;
}

- (void) ReadAboutXml
{
    NSString * XmlFile = [[NSBundle mainBundle] pathForResource: @"about" ofType: @"XML"];
    NSData * xmlData = [[NSData alloc] initWithContentsOfFile:XmlFile];
    XmlRows = [[NSMutableArray alloc] init];
    GDataXMLDocument * XmlDoc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:nil];
    if(XmlDoc != nil)
    {
        //XmlRows = [XmlDoc.rootElement elementsForName:@"Row"];
        NSArray * Rows = [XmlDoc.rootElement elementsForName:@"Row"];
        for(GDataXMLElement * oneXmlRow in Rows)
        {
            AboutRow * newRow = [[AboutRow alloc] init];
            GDataXMLNode * BgNode = [oneXmlRow attributeForName:@"Background"];
            [newRow setBackground:[BgNode stringValue]];
            GDataXMLNode * ImageNode = [oneXmlRow attributeForName:@"Image"];
            [newRow setImage:[ImageNode stringValue]];
            GDataXMLNode * qnameNode = [oneXmlRow attributeForName:@"qname"];
            [newRow setQname:[qnameNode stringValue]];
            GDataXMLNode * TextNode = [oneXmlRow attributeForName:@"Text"];
            [newRow setText:[TextNode stringValue]];
            [XmlRows addObject:newRow];
            //NSLog(@"Bg:%@,Image:%@,qname:%@,Text:%@",newRow.Background,newRow.Image,newRow.qname,newRow.Text);
        }
        
        
    }
    
}
#pragma mark - SliderViewController UIControl
-(void)slideViewController:(id)viewController setTitleLabel:(UILabel *)label
{
    label.text = @"關於";
}

@end
