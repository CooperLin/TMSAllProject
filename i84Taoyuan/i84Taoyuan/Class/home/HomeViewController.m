//
//  HomeViewController.m
//  i84Taoyuan
//
//  Created by TMS_APPLE on 2014/9/2.
//  Copyright (c) 2014年 TMS. All rights reserved.
//

#import "HomeViewController.h"
#import "AppDelegate.h"

@interface HomeViewController (){
//    SearchBusViewController2 * searchBusViewController2;
}
@property (strong, nonatomic) IBOutlet UIImageView *imageViewBackground;
//@property (strong,nonatomic) NSMutableArray *IndustryArray;

@property (weak, nonatomic) IBOutlet UIImageView * imgFunSelectBus;
@property (weak, nonatomic) IBOutlet UIImageView * imgFunSelectRoutePlan;
@property (weak, nonatomic) IBOutlet UIImageView * imgFunSelectFavorite;
@property (weak, nonatomic) IBOutlet UIImageView * imgFunSelectNearStop;
@property (weak, nonatomic) IBOutlet UIImageView * imgFunSelectNotification;
@property (weak, nonatomic) IBOutlet UIImageView * imgFunSelectAbout;

@end

@implementation HomeViewController

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
    if (IOSVersion<7.0)
    {
        [self.imageViewBackground setImage:[UIImage imageNamed:@"cover"]];
    }
    
    [self setFunSelect];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//- (IBAction)actButtonFunctionsTouchUpInside:(UIButton*)sender
//{
//    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(homeViewController:goToFunction:)])
//    {
//        [self.delegate homeViewController:self goToFunction:(SlideFunctionType)sender.tag];
//    }
//}

-(void)setFunSelect
{
    [self.imgFunSelectBus setUserInteractionEnabled:YES];
    [self.imgFunSelectRoutePlan setUserInteractionEnabled:YES];
    [self.imgFunSelectFavorite setUserInteractionEnabled:YES];
    [self.imgFunSelectNearStop setUserInteractionEnabled:YES];
    [self.imgFunSelectNotification setUserInteractionEnabled:YES];
    [self.imgFunSelectAbout setUserInteractionEnabled:YES];
    
    [self.imgFunSelectBus addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickFunSelect:)]];
    [self.imgFunSelectRoutePlan addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickFunSelect:)]];
    [self.imgFunSelectFavorite addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickFunSelect:)]];
    [self.imgFunSelectNearStop addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickFunSelect:)]];
    [self.imgFunSelectNotification addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickFunSelect:)]];
    [self.imgFunSelectAbout addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickFunSelect:)]];
    
}

-(void)clickFunSelect:(UITapGestureRecognizer*)gestRecognizer
{
    UIImageView * iv = (UIImageView*)gestRecognizer.view;
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(homeViewController:goToFunction:)])
    {
        [self.delegate homeViewController:self goToFunction:(int)iv.tag];
    }
}

@end
