//
//  ListViewController.h
//  i84Taoyuan
//
//  Created by TMS_APPLE on 2014/9/28.
//  Copyright (c) 2014年 Joe. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ListViewControllerDelegate <NSObject>
@optional
-(CGFloat)listViewController:(UIViewController*)viewController heightForRowAtIndexPath:(NSIndexPath *)indexPath;
-(CGFloat)listViewController:(UIViewController*)viewController heightForHeaderInSection:(NSInteger)section;
-(void)listViewController:(UIViewController*)viewController didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
-(NSInteger)numberOfSectionsInListViewController:(UIViewController*)viewController;
-(NSString *)listViewController:(UIViewController*)viewController titleForHeaderInSection:(NSInteger)section;
-(UITableViewCell *)listViewController:(UIViewController*)viewController cellForRowAtIndexPath:(NSIndexPath *)indexPath;
-(NSInteger)listViewController:(UIViewController*)viewController numberOfRowsInSection:(NSInteger)section;
-(void)viewDidAppearListViewController:(UIViewController *)viewController;
-(UIView *)listViewController:(UIViewController*)viewController viewForHeaderInSection:(NSInteger)section;

//Edit & Move
-(void)listViewController:(UIViewController *)viewController moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath;
-(void)listViewController:(UIViewController *)viewController commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;
-(BOOL)listViewController:(UIViewController *)viewController canMoveRowAtIndexPath:(NSIndexPath *)indexPath;

@required

@end
@interface ListViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITableView *tableViewResult;
@property (strong, nonatomic) IBOutlet UILabel *labelNotice;
@property (strong, nonatomic) id <ListViewControllerDelegate>delegate;
@property (assign,nonatomic)BOOL boolNow;
-(void)reloadListData;

@end
