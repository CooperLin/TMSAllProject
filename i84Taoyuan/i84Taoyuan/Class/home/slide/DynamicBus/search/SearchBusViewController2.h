//
//  SearchBusViewController2.h
//  i84Taoyuan
//
//  Created by TMS on 2014/11/24.
//  Copyright (c) 2014年 TMS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchBusViewController2 : UIViewController <UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UIView *ContentV;
@property (strong, nonatomic) IBOutlet UITableView *tableViewSearch;
@property (strong, nonatomic) IBOutlet UILabel *labelInput;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)actBtnNumbersTouchUpInside:(id)sender;

@end
