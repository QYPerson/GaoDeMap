//
//  UserLocation.m
//  GaoDeMapDemo
//
//  Created by zibin on 16/7/26.
//  Copyright © 2016年 zibin. All rights reserved.
//

#import "UserLocation.h"
#import <AMapLocationKit/AMapLocationKit.h>
#import <MAMapKit/MAMapKit.h>
@interface UserLocation () <AMapLocationManagerDelegate>
//位置管理者
@property (nonatomic, strong) AMapLocationManager *locationManager;
//地理编码器
@property(nonatomic,strong)CLGeocoder *geocoder;
//地址
@property (nonatomic,strong) NSString *userAddress;
//地址Block
@property (nonatomic,copy) void (^userAddressBlock)(CLPlacemark *placeMark);
//获取位置失败
@property (nonatomic,copy) void(^ErrorBlock)(NSError *error);
@end

@implementation UserLocation
#pragma mark - singleton
//单例
+ (UserLocation *)sharedUserLocationManager
{
    static UserLocation *sharedUserLocationManager = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedUserLocationManager = [[self alloc] init];
    });
    return sharedUserLocationManager;
}
#pragma mark - lazyLoad
-(CLGeocoder *)geocoder{
    if (!_geocoder) {
        _geocoder = [[CLGeocoder alloc] init];
    }
    return _geocoder;
}
//位置管理者
-(AMapLocationManager *)locationManager{
    if (!_locationManager) {
        _locationManager = [[AMapLocationManager alloc] init];
        [_locationManager setDelegate:self];
        [_locationManager setPausesLocationUpdatesAutomatically:NO];
        [_locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    }
    return _locationManager;
}

-(void)getUserLocationSuccess:(void (^)(NSString *userAddress))userAddress faild:(void (^)(NSError *))error{
    [self.locationManager startUpdatingLocation];
    
    //对block赋值
    self.userAddressBlock = ^(CLPlacemark *placemark){
        NSDictionary *tmpDic = placemark.addressDictionary;
        NSString *userLocation = tmpDic[@"FormattedAddressLines"][0];
        userLocation = [userLocation substringFromIndex:2];
        userAddress(userLocation);
    };
    self.ErrorBlock = ^(NSError *err){
        error(err);
    };
}
-(void)getUserLocationWithShopLocation:(CLLocationCoordinate2D )shopLocation Success:(void(^)(NSString *userAddress,BOOL isInTheRegino))userAddress faild:(void(^)(NSError *error))error{
    [self.locationManager startUpdatingLocation];
    //对block赋值
    self.userAddressBlock = ^(CLPlacemark *placemark){
        NSDictionary *tmpDic = placemark.addressDictionary;
        NSString *userLocation = tmpDic[@"FormattedAddressLines"][0];
        userLocation = [userLocation substringFromIndex:2];
        //判断商店坐标是否在圆内
        BOOL isContains = MACircleContainsCoordinate(placemark.location.coordinate, shopLocation, 200);
        userAddress(userLocation,isContains);
    };
    self.ErrorBlock = ^(NSError *err){
        error(err);
    };
}

#pragma mark - AMapLocationManagerDelegate
//定位成功
- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location
{
    //定位结果
    [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (placemarks.count == 0 || error) {
            NSLog(@"反编码失败");
        }else{//编码成功
            CLPlacemark *placemark =  [placemarks firstObject];
//            CLLocationCoordinate2D location2D =  placemark.location.coordinate;
            self.userAddressBlock(placemark);
            //停止定位
            [self.locationManager stopUpdatingLocation];
        }
    }];
    
}
//定位失败
- (void)amapLocationManager:(AMapLocationManager *)manager didFailWithError:(NSError *)error
{
    self.ErrorBlock(error);
}


@end

