//
//  Annotation.h
//  i84Taoyuan
//
//  Created by TMS APPLE on 13/8/22.
//  Copyright (c) 2013年 TMS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@interface Annotation : NSObject <MKAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, assign) BOOL state;
@property (nonatomic, strong) NSString *ID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *tel;
@property (nonatomic, strong) NSString *openTime;
@property (nonatomic, strong) NSString *limit;
@property (nonatomic, assign) NSInteger carTotal;
@property (nonatomic, assign) NSInteger carLeft;
@property (nonatomic, assign) float carRate;
@property (nonatomic, assign) NSInteger motorTotal;
@property (nonatomic, assign) NSInteger motorLeft;
@property (nonatomic, assign) float motorRate;
@property (nonatomic, assign) NSInteger bikeTotal;
@property (nonatomic, assign) NSInteger bikeLeft;
@property (nonatomic, assign) float bikeRate;
@property (nonatomic, strong) NSDate *updateTime;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, assign) float distance;


-(id) initWithCoordinate: (CLLocationCoordinate2D) theCoordinate;
-(id) initWithTitle:(NSString*)stringTitle subTitle:(NSString*)stringSubTitle coordinate:(CLLocationCoordinate2D)coordinate;

@end
