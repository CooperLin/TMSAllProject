//
//  ListViewController.m
//  i84Taoyuan
//
//  Created by TMS_APPLE on 2014/9/28.
//  Copyright (c) 2014年 Joe. All rights reserved.
//

#import "ListViewController.h"

@interface ListViewController ()
<
UITableViewDelegate
,UITableViewDataSource
>
@end

@implementation ListViewController

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
-(void)viewWillAppear:(BOOL)animated
{
    //    [self.labelNotice setText:ICLocalizedString(@"test", @"aaa")];
//    self.tableViewResult.frame = self.view.bounds;
}
-(void)viewDidAppear:(BOOL)animated
{
    if (self.delegate)
    {
        if ([self.delegate respondsToSelector:@selector(viewDidAppearListViewController:)])
        {
            [self.delegate viewDidAppearListViewController:self];
        }
    }
}
-(void)viewWillDisappear:(BOOL)animated
{
    self.delegate = nil;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)reloadListData
{
    [self.tableViewResult reloadData];
}
#pragma mark - UITableViewDelegate & DataSource
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * viewHeader = nil;
    if (self.delegate)
    {
        if ([self.delegate respondsToSelector:@selector(listViewController:viewForHeaderInSection:)])
        {
            viewHeader = [self.delegate listViewController:self viewForHeaderInSection:section];
        }
#ifdef debug
        else
        {
            if (!section)
            {
                NSLog(@"no responds for the protocol method");
            }
        }
    }
    else
    {
        if (!section)
        {
            NSLog(@"No delegate");
        }
#endif
    }
    return viewHeader;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger integerNumberOfSection = 1;
    if (self.delegate)
    {
        if ([self.delegate respondsToSelector:@selector(numberOfSectionsInListViewController:)])
        {
            integerNumberOfSection = [self.delegate numberOfSectionsInListViewController:self];
        }
#ifdef debug
        else
        {
            NSLog(@"no responds for the protocol method");
        }
    }
    else
    {
        NSLog(@"No delegate");
#endif
    }
    return integerNumberOfSection;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString * stringTitle = nil;
    if (self.delegate)
    {
        if ([self.delegate respondsToSelector:@selector(listViewController:titleForHeaderInSection:)])
        {
            stringTitle = [self.delegate listViewController:self titleForHeaderInSection:section];
        }
#ifdef debug
        else
        {
            if (!section)
            {
                NSLog(@"no responds for the protocol method");
            }
        }
    }
    else
    {
        if (!section)
        {
            NSLog(@"No delegate");
        }
#endif
    }
    return stringTitle;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger integerNumberOfRows = 0;
    if (self.delegate)
    {
        if ([self.delegate respondsToSelector:@selector(listViewController:numberOfRowsInSection:)])
        {
            integerNumberOfRows = [self.delegate listViewController:self numberOfRowsInSection:section];
        }
#ifdef debug
        else
        {
            if (!section)
            {
                NSLog(@"no responds for the protocol method");
            }
        }
    }
    else
    {
        if (!section)
        {
            NSLog(@"No delegate");
        }
#endif
    }
    return integerNumberOfRows;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = nil;
    if (self.delegate)
    {
        if ([self.delegate respondsToSelector:@selector(listViewController:cellForRowAtIndexPath:)])
        {
            cell = [self.delegate listViewController:self cellForRowAtIndexPath:indexPath];
        }
#ifdef debug
        else
        {
            if (!indexPath.section)
            {
                NSLog(@"no responds for the protocol method");
            }
        }
    }
    else
    {
        if (!indexPath.section)
        {
            NSLog(@"No delegate");
        }
#endif
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate)
    {
        if ([self.delegate respondsToSelector:@selector(listViewController:didSelectRowAtIndexPath:)])
        {
            [self.delegate listViewController:self didSelectRowAtIndexPath:indexPath];
        }
#ifdef debug
        else
        {
            if (!indexPath.section)
            {
                NSLog(@"no responds for the protocol method");
            }
        }
    }
    else
    {
        if (!indexPath.section)
        {
            NSLog(@"No delegate");
        }
#endif
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat floatHeaderHeight = 30.0;
    if (self.delegate)
    {
        if ([self.delegate respondsToSelector:@selector(listViewController:heightForHeaderInSection:)])
        {
            floatHeaderHeight = [self.delegate listViewController:self heightForHeaderInSection:section];
        }
        else
        {
            floatHeaderHeight = 0.0;
#ifdef debug

            if (!section)
            {
                NSLog(@"no responds for the protocol method");
            }
#endif
        }
    }
#ifdef debug
    else
    {
        if (!section)
        {
            NSLog(@"No delegate");
        }
    }
#endif

    return floatHeaderHeight;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat floatRowHeight = 44.0;
    
    if (self.delegate)
    {
        if ([self.delegate respondsToSelector:@selector(listViewController:heightForRowAtIndexPath:)])
        {
            floatRowHeight = [self.delegate listViewController:self heightForRowAtIndexPath:indexPath];
        }
#ifdef debug
        else
        {
            if (!indexPath.section)
            {
                NSLog(@"no responds for the protocol method");
            }
        }
    }
    else
    {
        if (!indexPath.section)
        {
            NSLog(@"No delegate");
        }
#endif
    }
    return floatRowHeight;
}
-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL boolResult = NO;
    if (self.delegate && [self.delegate respondsToSelector:@selector(listViewController:canMoveRowAtIndexPath:)])
    {
        [self.delegate listViewController:self canMoveRowAtIndexPath:indexPath];
    }
    return boolResult;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(listViewController:commitEditingStyle:forRowAtIndexPath:)])
    {
        [self.delegate listViewController:self commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
    }
    
}
-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(listViewController:moveRowAtIndexPath:toIndexPath:)])
    {
        [self.delegate listViewController:self moveRowAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
    }
}
@end
