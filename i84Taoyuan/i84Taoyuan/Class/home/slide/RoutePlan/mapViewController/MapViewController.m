//
//  mapViewController.m
//  i84Taoyuan
//
//  Created by TMS APPLE on 13/8/20.
//  Copyright (c) 2013年 TMS. All rights reserved.
//

#import "MapViewController.h"
#import "Annotation.h"

@interface MapViewController ()
<
MKMapViewDelegate
>
{
//    NSMutableArray * arrayBusStopsAnnotations;
    Annotation * annotationCenter;
    MKPolyline * polylineShow;
    Annotation * annotationSelected;
    UITapGestureRecognizer * gestureTap;
}
- (IBAction)actGoAnnotation:(id)sender;
@property (strong, nonatomic) IBOutlet MKMapView *mapviewMain;
@property (strong, nonatomic) IBOutlet UIButton *buttonReturn;

@end

@implementation MapViewController

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
//    [self actLocalVariableInit];
//    [self actAddNavigationBarItems];
    [self actSetMapAttributions];
//    NSLog(@"idRecieved %@",self.idRecieved);
}


//-(void)actAddNavigationButton
//{
//    UIBarButtonItem *navigationButton = [[UIBarButtonItem alloc]
//                                   initWithImage:[UIImage imageNamed:@"icon_26"]
//                                   style:UIBarButtonItemStyleBordered
//                                   target:self
//                                   action:@selector(actAddPolyLine)];
//    self.navigationItem.rightBarButtonItem = navigationButton;
//}
-(void)actAddPolyLineFromCoordinate:(CLLocationCoordinate2D)coordinateStart toCoordinate:(CLLocationCoordinate2D)coordinateEnd
{
    if (coordinateEnd.latitude == 0 && coordinateEnd.longitude ==0)
    {
        coordinateEnd = annotationCenter.coordinate;
    }
    if (coordinateStart.latitude == 0 && coordinateStart.longitude ==0)
    {
        coordinateEnd = self.mapviewMain.userLocation.coordinate;
    }

    CLLocation * locationStart = [[CLLocation alloc]initWithLatitude:coordinateStart.latitude longitude:coordinateStart.longitude];
    CLLocation * locationEnd = [[CLLocation alloc]initWithLatitude:coordinateEnd.latitude longitude:coordinateEnd.longitude];
    if ([locationStart distanceFromLocation:locationEnd]>5)
    {
        if (polylineShow)
        {
            [self.mapviewMain removeOverlay:polylineShow];
        }
        
        polylineShow = [RouteOverlayManager actGetRoutesFromCoordinate:self.mapviewMain.userLocation.coordinate ToCoordinate:annotationCenter.coordinate];
        if (polylineShow)
        {
            [self.mapviewMain addOverlay:polylineShow];
        }
    }
}

-(void)viewWillAppear:(BOOL)animated
{
//    NSLog(@"%@",self.idRecieved);
//    [self.mapviewMain removeAnnotations:self.mapviewMain.annotations];
    self.mapviewMain.centerCoordinate = self.mapviewMain.userLocation.coordinate;

    if (self.delegate)
    {
//        [self actPutAnnotationsOnMapView];
        [self.buttonReturn setHidden:YES];
    }
    
}
-(void)viewWillDisappear:(BOOL)animated
{
//    if (polylineShow)
//    {
//        [self.mapviewMain removeOverlay:polylineShow];
//    }
//    self.delegate = nil;
}
-(void)actChangeLocationToCoordinate:(CLLocationCoordinate2D)coordinate
{
    MKCoordinateRegion mapRegin;
    mapRegin.center = coordinate;

    mapRegin.span.latitudeDelta = 0.01;
    mapRegin.span.longitudeDelta = 0.01;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    
    [self.mapviewMain setRegion:mapRegin];
    
    [UIView commitAnimations];
}
//若由輸入annotations則以輸入為主
//若annotations == nil 則經過delegate要
-(void)actPutOnMapViewWithAnnotations:(NSArray *)annotations
{
    [self.mapviewMain removeAnnotations:self.mapviewMain.annotations];
    
    BOOL boolAnnotations = annotations.count;
    
    //宣告Map Region 顯示區域
    MKCoordinateRegion mapRegin;
    
    /*顯示臺灣
     //指定地圖中心座標
     mapRegin.center = CLLocationCoordinate2DMake(23.7, 121.05);
     //設定地圖比例
     mapRegin.span.latitudeDelta = 3.2;
     mapRegin.span.longitudeDelta = 3.2;
     */
    //指定地圖中心座標
    CLLocationCoordinate2D coordinateCenter = CLLocationCoordinate2DMake(23.837, 121.011);
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(mapViewDefultCenter)])
    {
        coordinateCenter = [self.delegate mapViewDefultCenter];
    }
    mapRegin.center = coordinateCenter;
    
    //設定地圖比例
    mapRegin.span.latitudeDelta = 0.1;
    mapRegin.span.longitudeDelta = 0.1;
    
        NSInteger integerAnnotationsCount = 0;
        
    if(boolAnnotations)
    {
        [self.mapviewMain addAnnotations:annotations];
        integerAnnotationsCount = annotations.count;
    }
    else if (self.delegate && [self.delegate respondsToSelector:@selector(numberOfAnnotationsOnMapView:)])
    {
        integerAnnotationsCount = [self.delegate numberOfAnnotationsOnMapView:self];
    }
    
    if (integerAnnotationsCount>0)
    {
        Annotation * annotation;
        CLLocationCoordinate2D coordinateMax = CLLocationCoordinate2DMake(21.0, 120.0);
        CLLocationCoordinate2D coordinateMin = CLLocationCoordinate2DMake(26.0, 122.0);
        
        for (int index = 0; index < integerAnnotationsCount;index++ )
        {
            CLLocationCoordinate2D coordinate;
            if (!boolAnnotations)
            {
                NSString * stringTitle = nil;
                if (self.delegate && [self.delegate respondsToSelector:@selector(numberOfAnnotationsOnMapView:)])
                {
                    stringTitle = [self.delegate mapView:self titleOnAnnotationAtIndex:index];
                }
                NSString * stringSubTitle = nil;
                if (self.delegate && [self.delegate respondsToSelector:@selector(numberOfAnnotationsOnMapView:)])
                {
                    stringSubTitle = [self.delegate mapView:self subTitleOnAnnotationAtIndex:index];
                }
                if (self.delegate && [self.delegate respondsToSelector:@selector(numberOfAnnotationsOnMapView:)])
                {
                    coordinate = [self.delegate mapView:self coordinateOnAnnotationAtIndex:index];
                }
                annotation = [[Annotation alloc]initWithTitle:stringTitle
                                                     subTitle:stringSubTitle
                                                   coordinate:coordinate];
                [self.mapviewMain addAnnotation:annotation];
            }
            else
            {
                annotation = [annotations objectAtIndex:index];
            }
            
            if (annotation.coordinate.longitude>120.0
                && annotation.coordinate.longitude<125.0
                && annotation.coordinate.latitude>21.0
                && annotation.coordinate.latitude<26.0
                )
            {
                if (annotation.coordinate.longitude>coordinateMax.longitude)
                {
                    coordinateMax.longitude = annotation.coordinate.longitude;
                }
                
                if (annotation.coordinate.longitude<coordinateMin.longitude)
                {
                    coordinateMin.longitude = annotation.coordinate.longitude;
                }
                
                if (annotation.coordinate.latitude>coordinateMax.latitude)
                {
                    coordinateMax.latitude = annotation.coordinate.latitude;
                }
                
                if (annotation.coordinate.latitude<coordinateMin.latitude)
                {
                    coordinateMin.latitude = annotation.coordinate.latitude;
                }
            }
        }
        
        CLLocationCoordinate2D coordinateCenter = CLLocationCoordinate2DMake((coordinateMax.latitude + coordinateMin.latitude)/2, (coordinateMax.longitude + coordinateMin.longitude)/2);
        
        //指定地圖中心座標
        mapRegin.center = coordinateCenter;
        
        //設定地圖比例
        mapRegin.span.latitudeDelta = fabs(coordinateMax.latitude - coordinateMin.latitude)+0.005;
        mapRegin.span.longitudeDelta = fabs(coordinateMax.longitude - coordinateMin.longitude)+0.005;
        //            if (mapRegin.span.longitudeDelta<=0)
        //            {
        //                NSLog(@"\nlon max:%f min:%f",coordinateMax.longitude,coordinateMin.longitude);
        //                return;
        //            }
        //            if (mapRegin.span.latitudeDelta<=0)
        //            {
        //                NSLog(@"\nlat max:%f min:%f",coordinateMax.latitude,coordinateMin.latitude);
        //                return;
        //            }
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    
    if (![self.delegate respondsToSelector:@selector(mapView:mapCenterChangeToCoordinate:)])
    {
        [self.mapviewMain setRegion:mapRegin];
    }
    
    [UIView commitAnimations];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - methods
//-(void)actLocalVariableInit
//{
//    arrayBusStopsAnnotations = [NSMutableArray new];
//}
//地圖在navigationbar上加 清除annotations 按鈕
//-(void)actAddNavigationBarItems
//{
//    UIBarButtonItem *navigationButtonClearAnnotation = [[UIBarButtonItem alloc]initWithTitle:@"清除" style:UIBarButtonItemStyleBordered target:self action:@selector(actClearAnnotations)];
//    self.navigationItem.rightBarButtonItem = navigationButtonClearAnnotation;
//}

//-(void)actClearAnnotations
//{
//    [self.mapviewMain removeAnnotations:arrayBusStopsAnnotations];
//    [arrayBusStopsAnnotations removeAllObjects];
//    [self.mapviewMain addAnnotation:annotationCenter];
//    [arrayBusStopsAnnotations addObject:annotationCenter];
//}

-(void)actSetMapAttributions
{
//    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
//                                          initWithTarget:self action:@selector(handleLongPress:)];
    gestureTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(actMapTapped:)];
//    lpgr.minimumPressDuration = 0.5; //user needs to press for 2 seconds
    if (self.delegate)
    {
        if (![self.delegate respondsToSelector:@selector(mapViewCloseTappedMode)]||![self.delegate mapViewCloseTappedMode])
        {
            [self.mapviewMain addGestureRecognizer:gestureTap];
        }
    }
    //設定map type(不設也是使用MKMapTypeStandard)
//    [self.mapviewMain setMapType:MKMapTypeStandard];
    
    //顯示使用者位置 xib已設定
//    self.mapviewMain.showsUserLocation = YES;
}
//- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer
-(void)actMapTapped:(UIGestureRecognizer *)gestureRecognizer
{
//    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
//        return;
    //裝換螢幕座標到地圖座標
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapviewMain];
    CLLocationCoordinate2D touchMapCoordinate =
    [self.mapviewMain convertPoint:touchPoint toCoordinateFromView:self.mapviewMain];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(mapView:didTappedOnCoordinate:)])
    {
        [self.delegate mapView:self didTappedOnCoordinate:touchMapCoordinate];
    }
    else
    {
        Annotation * annotation = [[Annotation alloc]initWithCoordinate:touchMapCoordinate];
        [self actPutOnMapViewWithAnnotations:@[annotation]];
    }
}
-(void)actSetCoordinateToCenter:(CLLocationCoordinate2D)coordinate
{
    //宣告Map Region 顯示區域
    MKCoordinateRegion mapReginBusStop;
    
    //設定地圖比例
    mapReginBusStop.span.latitudeDelta = 0.01;
    mapReginBusStop.span.longitudeDelta = 0.01;
    
    //指定地圖中心座標
    mapReginBusStop.center = coordinate;

    [self.mapviewMain setRegion:mapReginBusStop];
}

#pragma mark - Events
//回到車站
- (IBAction)actGoAnnotation:(id)sender
{
    [self actSetCoordinateToCenter:annotationCenter.coordinate];
}
#pragma mark - MKMapViewDelegate
-(void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {

}
-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(mapView:mapCenterChangeToCoordinate:)])
    {
        [self.delegate mapView:self mapCenterChangeToCoordinate:self.mapviewMain.centerCoordinate];
    }
}
-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(mapView:didUpdateUserLocation:)])
    {
        [self.delegate mapView:self didUpdateUserLocation:userLocation.coordinate];
    }

}
-(MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
    MKPolylineView * polylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
    polylineView.lineWidth = 5.0f;
    polylineView.strokeColor = [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:1.0];
    return polylineView;
}
-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    annotationSelected = view.annotation;

    if (self.delegate && [self.delegate respondsToSelector:@selector(mapView:didSelectAnnotation:)])
    {
        [self.delegate mapView:self didSelectAnnotation:annotationSelected];
    }
}
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    //判斷Pin如果是目前位置就不修改
    if ([annotation isKindOfClass:[MKUserLocation class]])
    {
        return nil;
    }
    
    MKPinAnnotationView *pinView = [[MKPinAnnotationView alloc]
                                    initWithAnnotation:annotation reuseIdentifier:@"PinView"];
    
    //設定圖樣
    if (self.delegate && [self.delegate respondsToSelector:@selector(mapView:imageForAnnotation:)])
    {
        pinView.image = [self.delegate mapView:self imageForAnnotation:annotation];
        
    }
    else
    {

    //設定顏色
//    pinView.pinColor = MKPinAnnotationColorGreen;
    }
    
    //重設圖片大小與座標
//    imageView.frame = CGRectMake(0, 0, 30, 30);
    
    //設定註解內的圖片
//    pinView.rightCalloutAccessoryView = imageView;
    
    //點擊時是否出現註解
    pinView.canShowCallout = YES;
    
    //是否可以被拖曳
//    pinView.animatesDrop = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(mapView:showCallOutDetailButtonOnAnnotation:)]&& [self.delegate respondsToSelector:@selector(mapView:didTappedDetailButtonOnAnnotation:)])
    {
        if ([self.delegate mapView:self showCallOutDetailButtonOnAnnotation:annotation])
        {
            UIButton * btnDetail = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            [btnDetail addTarget:self action:@selector(actPinViewDetailBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
            pinView.rightCalloutAccessoryView = btnDetail;
        }
        else
        {
            
        }
    }
    return pinView;
}
-(void)actPinViewDetailBtnTapped:(UIButton*)sender
{
    [self.delegate mapView:self didTappedDetailButtonOnAnnotation:annotationSelected];
}
-(void)actSelectAnnotation:(Annotation *)annotation
{
    [self.mapviewMain selectAnnotation:annotation animated:YES];
}
@end
