//
//  ViewController.m
//  GaoDeMapDemo
//
//  Created by zibin on 16/7/22.
//  Copyright © 2016年 zibin. All rights reserved.
//

//屏幕宽
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
//商店坐标  根据商店实际坐标自行修改
#define  LATITUD   30.2482103207 //经度
#define  LONGITUDE 120.0590317867 //纬度
//派送半径 根据实际派送范围自行修改 (单位：米)
#define  RADIUS 10000.0

#import "SendRangeVC.h"
#import <MAMapKit/MAMapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "CurrentLocationView.h"
#import "SDCycleScrollView.h"

//遵循 MAMapViewDelegate AMapLocationManagerDelegate 代理
@interface SendRangeVC ()<MAMapViewDelegate,AMapLocationManagerDelegate,SDCycleScrollViewDelegate>
//点标注数据
@property (nonatomic,strong) MAPointAnnotation *pointAnnotation;
//商店坐标
@property (nonatomic,assign) CLLocationCoordinate2D shopLocation;
//位置范围数组
@property (nonatomic, strong) NSMutableArray *regions;
//显示用户位置的Lable
@property (nonatomic,weak) CurrentLocationView *locationView;
//地理编码器
@property(nonatomic,strong)CLGeocoder *geocoder;
//轮播图
@property (nonatomic,weak) SDCycleScrollView *cycleScrollView;



@end

@implementation SendRangeVC
#pragma mark - lazyLoad
//懒加载
-(CLGeocoder *)geocoder{
    if (!_geocoder) {
        _geocoder = [[CLGeocoder alloc] init];
    }
    return _geocoder;
}

-(NSMutableArray *)regions{
    if (!_regions) {
        _regions = [[NSMutableArray alloc] init];
    }
    return _regions;
}

-(CLLocationCoordinate2D)shopLocation{
    if (!_shopLocation.latitude) {
        _shopLocation = CLLocationCoordinate2DMake(LATITUD, LONGITUDE);
    }
    return _shopLocation;
    
}

#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"派送范围";
    [self.view setBackgroundColor:[UIColor whiteColor]];
    //初始化地图
    [self initMapView];
    //标记数据
    [self setPointAnnotation];
    //配置位置管理者
    [self configLocationManager];
    //用户位置Label
    [self addUserLocationLabel];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.toolbar.translucent   = YES;
    self.navigationController.toolbarHidden         = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //获得当前位置
    [self getCurrentLocation];
    //根据商店经纬度添加圆
    [self addCircleReionForCoordinate:self.shopLocation];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.regions enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.locationManager stopMonitoringForRegion:(AMapLocationRegion *)obj];
    }];
}


#pragma mark - Initialization
//初始化地图
- (void)initMapView
{
    if (self.mapView == nil)
    {
        self.mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 140, SCREEN_WIDTH, SCREEN_HEIGHT-80)];
        [self.mapView setDelegate:self];
        self.mapView.showsUserLocation = YES;
        self.mapView.showsScale = NO;
        [self.view addSubview:self.mapView];
    }
}

//标记数据
-(void)setPointAnnotation{

    MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
    pointAnnotation.coordinate = self.shopLocation;
    pointAnnotation.title = @"杭州西溪元店";
    self.pointAnnotation = pointAnnotation;
    [self.mapView addAnnotation:pointAnnotation];
    [self.mapView selectAnnotation:pointAnnotation animated:YES];
    
}

//用户位置
-(void)addUserLocationLabel{
    CurrentLocationView *locationView = [[[NSBundle mainBundle] loadNibNamed:@"CurrentLocationView" owner:nil options:nil] lastObject];
    locationView.frame  = CGRectMake(0, 60, SCREEN_WIDTH, 80);
    self.locationView = locationView;
    __weak typeof(self) weakSelf = self;
    locationView.ModifyAdrBtnClick = ^{
    
//        weakSelf.navigationController pushViewController:<#(nonnull UIViewController *)#> animated:<#(BOOL)#>
        
    };
    [self.view addSubview:locationView];

}
- (void)configLocationManager
{
    self.locationManager = [[AMapLocationManager alloc] init];
    
    [self.locationManager setDelegate:self];
    
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    
    [self.locationManager setPausesLocationUpdatesAutomatically:NO];
    
    [self.locationManager setAllowsBackgroundLocationUpdates:YES];
}
#pragma mark - Add Regions
- (void)getCurrentLocation
{
    __weak typeof(self) weakSelf = self;
    [self.locationManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //回调或者说是通知主线程刷新，
            //反地理编码
            [weakSelf.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
                if (placemarks.count == 0 || error) {
                     NSLog(@"没有定位到");
                }else{//编码成功
                CLPlacemark *placemark =  [placemarks firstObject];
                NSString *userLocation =  [placemark.name substringFromIndex:2];
                weakSelf.locationView.userLocation.text =[NSString stringWithFormat:@"%@" ,userLocation];
                }
            }];
        });
    }];
    
}
//根据商店经纬度添加圆
- (void)addCircleReionForCoordinate:(CLLocationCoordinate2D)coordinate
{

    AMapLocationCircleRegion *cirRegion300 = [[AMapLocationCircleRegion alloc] initWithCenter:coordinate radius:RADIUS identifier:@"circleRegion300"];
    //添加地理围栏
    [self.locationManager startMonitoringForRegion:cirRegion300];
    //保存地理围栏
    [self.regions addObject:cirRegion300];
    //添加Overlay
    MACircle *circle300 = [MACircle circleWithCenterCoordinate:coordinate radius:RADIUS];
    [self.mapView addOverlay:circle300];
    //设置地图显示范围
    [self.mapView setVisibleMapRect:circle300.boundingMapRect];
}


#pragma mark -  MAMapViewDelegate
//返回大头针View
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *pointReuseIndentifier = @"pointReuseIndentifier";
        MAPinAnnotationView *annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndentifier];
        }
        annotationView.canShowCallout= YES;       //设置气泡可以弹出，默认为NO
        annotationView.animatesDrop = YES;        //设置标注动画显示，默认为NO
        annotationView.draggable = YES;        //设置标注可以拖动，默认为NO
        annotationView.pinColor = MAPinAnnotationColorPurple;
        return annotationView;
    }
    return nil;
}
//返回圆形覆盖物
- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[MAPolygon class]])
    {
        MAPolygonRenderer *polylineRenderer = [[MAPolygonRenderer alloc] initWithPolygon:overlay];
        polylineRenderer.lineWidth = 1.0f;
        polylineRenderer.strokeColor = [UIColor redColor];
        return polylineRenderer;
    }
    else if ([overlay isKindOfClass:[MACircle class]])
    {
        MACircleRenderer *circleRenderer = [[MACircleRenderer alloc] initWithCircle:overlay];
        circleRenderer.lineWidth = 0.0f;
        //边界颜色
        circleRenderer.strokeColor = [UIColor orangeColor];
        circleRenderer.fillColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:0.2];
        return circleRenderer;
    }
    
    return nil;
}

//点击气泡回调
-(void)mapView:(MAMapView *)mapView didAnnotationViewCalloutTapped:(MAAnnotationView *)view{
    //添加轮播图
    // 网络加载图片的轮播器
//    SDCycleScrollView *cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 140, SCREEN_WIDTH, SCREEN_HEIGHT - 140)  delegate:self placeholderImage:[UIImage imageNamed:@"shopPic"]];
//    cycleScrollView.imageURLStringsGroup = [NSArray array];
    
    // 本地加载图片的轮播器
     SDCycleScrollView *cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 140, SCREEN_WIDTH, SCREEN_HEIGHT - 140) imageNamesGroup:[NSArray arrayWithObjects:@"shopPic", @"shopPic",@"shopPic",@"shopPic",nil]];
    cycleScrollView.delegate = self;
    cycleScrollView.autoScrollTimeInterval = 3;
    self.cycleScrollView = cycleScrollView;
    [self.view addSubview:cycleScrollView];
    
}
#pragma mark - AMapLocationManagerDelegate 
//地理围栏的相关回调
- (void)amapLocationManager:(AMapLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"~~~locationError:{%ld;%@}", (long)error.code, error.localizedDescription);
}

- (void)amapLocationManager:(AMapLocationManager *)manager didStartMonitoringForRegion:(AMapLocationRegion *)region
{
    NSLog(@"didStartMonitoringForRegion:%@", region);
}

- (void)amapLocationManager:(AMapLocationManager *)manager monitoringDidFailForRegion:(AMapLocationRegion *)region withError:(NSError *)error
{
    NSLog(@"monitoringDidFailForRegion:%@", error.localizedDescription);
}

- (void)amapLocationManager:(AMapLocationManager *)manager didEnterRegion:(AMapLocationRegion *)region
{
    NSLog(@"didEnterRegion:%@", region);
}

- (void)amapLocationManager:(AMapLocationManager *)manager didExitRegion:(AMapLocationRegion *)region
{
    NSLog(@"didExitRegion:%@", region);
}

- (void)amapLocationManager:(AMapLocationManager *)manager didDetermineState:(AMapLocationRegionState)state forRegion:(AMapLocationRegion *)region
{
    NSLog(@"didDetermineState:%@; state:%ld", region, (long)state);
}

#pragma mark - SDCycleScrollViewDelegate
/** 点击图片回调 */
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index{
    [self.cycleScrollView removeFromSuperview];
}


@end

