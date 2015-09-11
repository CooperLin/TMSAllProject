//
//  RouteOverlayManager.h
//  i84Taoyuan
//
//  Created by TMS_APPLE on 2014/9/19.
//  Copyright (c) 2014年 TMS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#define GoogleRouteAPI @"http://maps.googleapis.com/maps/api/directions/json?origin=%f,%f&destination=%f,%f&alternatives=False&units=metric&mode=%@&language=Zh-Tw&sensor=true"


@interface RouteOverlayManager : NSObject

+(MKPolyline*)actGetRoutesFromCoordinate:(CLLocationCoordinate2D)coordinateStart ToCoordinate:(CLLocationCoordinate2D)coordinateEnd;

@end
