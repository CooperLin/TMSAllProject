//
//  mapViewController.h
//  i84Taoyuan
//
//  Created by TMS APPLE on 13/8/20.
//  Copyright (c) 2013年 TMS. All rights reserved.
//



#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Annotation.h"
#import "RouteOverlayManager.h"

@protocol MapViewControllerDelegate <NSObject>
@required
@optional

//-(NSArray*)showAnnotationsOnMapView:(UIViewController*)mapView;
-(CLLocationCoordinate2D)mapViewDefultCenter;
-(BOOL)mapViewCloseTappedMode;
-(void)mapView:(UIViewController *)mapView didUpdateUserLocation:(CLLocationCoordinate2D)userLocation;
-(NSInteger)numberOfAnnotationsOnMapView:(UIViewController *)mapView;
-(NSString*)mapView:(UIViewController *)mapView titleOnAnnotationAtIndex:(NSInteger)index;
-(NSString*)mapView:(UIViewController *)mapView subTitleOnAnnotationAtIndex:(NSInteger)index;
-(void)mapView:(UIViewController *)mapView mapCenterChangeToCoordinate:(CLLocationCoordinate2D)coordinate;

-(CLLocationCoordinate2D)mapView:(UIViewController *)mapView coordinateOnAnnotationAtIndex:(NSInteger)index;
//view的Title
-(NSString*)titleOnMapView:(UIViewController *)mapView;
-(void)mapView:(UIViewController *)mapView didTappedOnCoordinate:(CLLocationCoordinate2D)coordinate;
-(UIImage*)mapView:(UIViewController*)mapView imageForAnnotation:(id<MKAnnotation>)annotation;
-(BOOL)mapView:(UIViewController *)mapView showCallOutDetailButtonOnAnnotation:(id<MKAnnotation>)annotation;

-(void)mapView:(UIViewController *)mapView didTappedDetailButtonOnAnnotation:(id<MKAnnotation>)annotation;
-(void)mapView:(UIViewController *)mapView didSelectAnnotation:(id<MKAnnotation>)annotation;

@end

@interface MapViewController : UIViewController<MKMapViewDelegate>
@property (strong, nonatomic) id <MapViewControllerDelegate>delegate;
//若annotations為nil或count=0 則觸發上面delegate numberOf Annotations.....
-(void)actPutOnMapViewWithAnnotations:(NSArray*)annotations
;
-(void)actAddPolyLineFromCoordinate:(CLLocationCoordinate2D)coordinateStart toCoordinate:(CLLocationCoordinate2D)coordinateEnd;
-(void)actSelectAnnotation:(Annotation*)annotation;
-(void)actChangeLocationToCoordinate:(CLLocationCoordinate2D)coordinate;

//idRecieved Array格式
@end
