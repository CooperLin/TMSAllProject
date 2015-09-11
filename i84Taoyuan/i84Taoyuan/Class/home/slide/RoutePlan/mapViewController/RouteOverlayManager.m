//
//  RouteOverlayManager.m
//  i84Taoyuan
//
//  Created by TMS_APPLE on 2014/9/19.
//  Copyright (c) 2014年 TMS. All rights reserved.
//
#import "ShareTools.h"
#import "RouteOverlayManager.h"

@implementation RouteOverlayManager
+(MKPolyline*)actGetRoutesFromCoordinate:(CLLocationCoordinate2D)coordinateStart ToCoordinate:(CLLocationCoordinate2D)coordinateEnd
{
    if(![ShareTools connectedToNetwork])
    {
        return nil;
    }
    NSString * urlstr = [[NSString alloc] initWithFormat:GoogleRouteAPI,
                         coordinateStart.latitude,
                         coordinateStart.longitude,
                         coordinateEnd.latitude,
                         coordinateEnd.longitude,@"walking"];
    
    NSURL * url = [NSURL URLWithString:[urlstr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"Url:%@",url);
//
//    RouteRequest = [ASIHTTPRequest requestWithURL:url];
//    [RouteRequest setDelegate:self];
//    [RouteRequest setDidFinishSelector:@selector(RouteRequestFinish:)];
//    //    [RouteRequest startAsynchronous];
//    [queue addOperation:RouteRequest];
    //NSURLSession
    
//    NSString *stringApiRequest=[NSString stringWithContentsOfURL:url encoding:4 error:nil ];

    NSError * errorJson;
    NSData * dataRequest = [NSData dataWithContentsOfURL:url];
    id idMutableContainer = [NSJSONSerialization JSONObjectWithData:dataRequest options:NSJSONReadingMutableContainers error:&errorJson];
    MKPolyline * polyline = nil;
    if (idMutableContainer)
    {
        if (errorJson)
        {
            NSLog(@"error when serialization json ,%@",errorJson);
        }
        if ([idMutableContainer isKindOfClass:[NSDictionary class]])
        {
            if ([[idMutableContainer objectForKey:@"status"]isEqualToString:@"OK"])
            {
                @try
                {
                    NSString *stringRoutePolyline = [[[[idMutableContainer objectForKey:@"routes"]objectAtIndex:0]objectForKey:@"overview_polyline"]objectForKey:@"points"];
                    polyline = [RouteOverlayManager polylineWithEncodedString:stringRoutePolyline];
                }
                @catch (NSException *exception) {
                    NSLog(@"exception:%@",exception);
                }
                @finally
                {
                    
                }
            }
            return polyline;
        }
    }
    return nil;
}
+ (MKPolyline *)polylineWithEncodedString:(NSString *)encodedString
{
    const char *bytes = [encodedString UTF8String];
    NSUInteger length = [encodedString lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    NSUInteger idx = 0;
    
    NSUInteger count = length / 4;
    CLLocationCoordinate2D *coords = calloc(count, sizeof(CLLocationCoordinate2D));
    NSUInteger coordIdx = 0;
    
    float latitude = 0;
    float longitude = 0;
    while (idx < length) {
        char byte = 0;
        int res = 0;
        char shift = 0;
        
        do {
            byte = bytes[idx++] - 63;
            res |= (byte & 0x1F) << shift;
            shift += 5;
        } while (byte >= 0x20);
        
        float deltaLat = ((res & 1) ? ~(res >> 1) : (res >> 1));
        latitude += deltaLat;
        
        shift = 0;
        res = 0;
        
        do {
            byte = bytes[idx++] - 0x3F;
            res |= (byte & 0x1F) << shift;
            shift += 5;
        } while (byte >= 0x20);
        
        float deltaLon = ((res & 1) ? ~(res >> 1) : (res >> 1));
        longitude += deltaLon;
        
        float finalLat = latitude * 1E-5;
        float finalLon = longitude * 1E-5;
        
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(finalLat, finalLon);
        coords[coordIdx++] = coord;
        
        if (coordIdx == count) {
            NSUInteger newCount = count + 10;
            coords = realloc(coords, newCount * sizeof(CLLocationCoordinate2D));
            count = newCount;
        }
    }
    
    MKPolyline *polyline = [MKPolyline polylineWithCoordinates:coords count:coordIdx];
    free(coords);
    
    return polyline;
}

@end
