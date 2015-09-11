//
//  AboutViewController.h
//  i84-TaichungV2
//
//  Created by ＴＭＳ 景翊科技 on 2014/3/7.
//  Copyright (c) 2014年 ＴＭＳ 景翊科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AboutViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,retain)    IBOutlet UIView * ContentV;
@property (nonatomic,retain)    IBOutlet UILabel * VersionLbl;
@property (nonatomic,retain)    IBOutlet UILabel * AttractionVersionLbl;
@property (nonatomic,retain)    IBOutlet UITableView * AboutTv;


@end
@interface AboutRow : NSObject

@property (nonatomic,retain) NSString * Background;
@property (nonatomic,retain) NSString * Image;
@property (nonatomic,retain) NSString * qname;
@property (nonatomic,retain) NSString * Text;

@end

