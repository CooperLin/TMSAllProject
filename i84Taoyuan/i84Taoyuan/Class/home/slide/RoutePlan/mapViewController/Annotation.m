//
//  busStopAnnotation.m
//  i84Taoyuan
//
//  Created by TMS APPLE on 13/8/22.
//  Copyright (c) 2013年 TMS. All rights reserved.
//

#import "Annotation.h"

@implementation Annotation
@synthesize coordinate;
@synthesize title;
@synthesize subtitle;

-(id) initWithCoordinate: (CLLocationCoordinate2D) theCoordinate
{
    if (self = [super init])
    {
        coordinate = theCoordinate;
    }
    return self;
}

-(id) initWithTitle:(NSString*)stringTitle subTitle:(NSString*)stringSubTitle coordinate:(CLLocationCoordinate2D)coordinateInit
{
    if (self = [super init])
    {
        title = stringTitle;
        subtitle = stringSubTitle;
        coordinate = coordinateInit;
    }

    return self;
}
@end
