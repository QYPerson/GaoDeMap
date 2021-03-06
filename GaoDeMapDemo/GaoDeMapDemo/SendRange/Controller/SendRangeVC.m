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
#import "Catagory.h"
#import <AMapLocationKit/AMapLocationKit.h>
#import "UserLocation.h"
#import "ChooseAddressVC.h"

//遵循 MAMapViewDelegate AMapLocationManagerDelegate 代理
@interface SendRangeVC ()<MAMapViewDelegate,SDCycleScrollViewDelegate>
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
//用户位置
@property (nonatomic,strong) UserLocation *userLoaction ;

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
    //气泡数据
    [self setPointAnnotation];
    //用户位置Label
    [self addUserLocationLabel];
    //根据商店经纬度添加覆盖物
    [self addCircleReionForCoordinate:self.shopLocation];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.toolbar.translucent   = YES;
    self.navigationController.toolbarHidden         = YES;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //1.创建用户位置管理者
    UserLocation *userLoaction = [UserLocation sharedUserLocationManager];
    //2.强引用 防止销毁
    self.userLoaction = userLoaction;
    //3.获取用户当前位置
    [self.userLoaction getUserLocationWithShopLocation:CLLocationCoordinate2DMake(LATITUD, LONGITUDE) Success:^(NSString *userAddress, BOOL isInTheRegino) {
        
        self.locationView.userLocation.text =[NSString stringWithFormat:@"%@" ,userAddress];
        
        if (isInTheRegino) {
            self.locationView.sendRange.textColor = [UIColor blackColor];
            self.locationView.sendRange.text = [NSString stringWithFormat:@"可由鲜在时杭州西溪园店配送"];
        }else{
            self.locationView.sendRange.textColor = [UIColor colorWithRed:235/255.0 green:56/255.0 blue:35/255.0 alpha:1];
            self.locationView.sendRange.text = [NSString stringWithFormat:@"您当前的位置不在派送范围内，请修改配送地址!"];
        }
    } faild:^(NSError *error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"定位失败" message:@"请打开定位，确定当前位置是否在派送范围" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alertView show];
    }];
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
        self.mapView.showsScale = NO;
        [self.view addSubview:self.mapView];
    }
}

//设置气泡数据
-(void)setPointAnnotation{

    MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
    pointAnnotation.coordinate = self.shopLocation;
    pointAnnotation.title = @"杭州西溪元店";
    self.pointAnnotation = pointAnnotation;
    [self.mapView addAnnotation:pointAnnotation];
    [self.mapView selectAnnotation:pointAnnotation animated:YES];
    
}

//添加用户位置视图
-(void)addUserLocationLabel{
    CurrentLocationView *locationView = [[[NSBundle mainBundle] loadNibNamed:@"CurrentLocationView" owner:nil options:nil] lastObject];
    locationView.frame  = CGRectMake(0, 60, SCREEN_WIDTH, 80);
    self.locationView = locationView;
    __weak typeof(self) weakSelf = self;
    locationView.ModifyAdrBtnClick = ^{
        [weakSelf.navigationController pushViewController:[[ChooseAddressVC alloc] init] animated:YES];
    };
    [self.view addSubview:locationView];

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
    
    //改变地图中心点
    self.mapView.centerCoordinate = coordinate;

}


#pragma mark -  MAMapViewDelegate
//返回大头针View
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *pointReuseIndentifier = @"pointReuseIndentifier";
        MAAnnotationView *annotationView = (MAAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
        if (annotationView == nil)
        {
            annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndentifier];
        }
        annotationView.canShowCallout= YES;       //设置气泡可以弹出，默认为NO
        annotationView.image = [UIImage imageNamed:@"dizhi"];
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
#pragma mark - SDCycleScrollViewDelegate
//点击轮播图
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index{
    [self.cycleScrollView removeFromSuperview];
}


- (void)amapLocationManager:(AMapLocationManager *)manager didEnterRegion:(AMapLocationRegion *)region{
    NSLog(@"%@",@"123");

}

/**
 *  离开region回调函数
 *
 *  @param manager 定位 AMapLocationManager 类。
 *  @param region 离开的region。
 */
- (void)amapLocationManager:(AMapLocationManager *)manager didExitRegion:(AMapLocationRegion *)region{
    NSLog(@"%@",@"456");

}


@end

